require 'rails_helper'
require 'models/application_model_examples'
require 'models/concerns/has_groups_examples'
require 'models/concerns/has_history_examples'
require 'models/concerns/has_roles_examples'
require 'models/concerns/has_groups_permissions_examples'
require 'models/concerns/has_xss_sanitized_note_examples'
require 'models/concerns/can_be_imported_examples'
require 'models/concerns/can_lookup_examples'
require 'models/concerns/has_object_manager_attributes_validation_examples'

RSpec.describe User, type: :model do
  subject(:user) { create(:user) }

  let(:customer) { create(:customer_user) }
  let(:agent)    { create(:agent_user) }
  let(:admin)    { create(:admin_user) }

  it_behaves_like 'ApplicationModel', can_assets: { associations: :organization }
  it_behaves_like 'HasGroups', group_access_factory: :agent_user
  it_behaves_like 'HasHistory'
  it_behaves_like 'HasRoles', group_access_factory: :agent_user
  it_behaves_like 'HasXssSanitizedNote', model_factory: :user
  it_behaves_like 'HasGroups and Permissions', group_access_no_permission_factory: :user
  it_behaves_like 'CanBeImported'
  it_behaves_like 'CanLookup'
  it_behaves_like 'HasObjectManagerAttributesValidation'

  describe 'Class methods:' do
    describe '.authenticate' do
      subject(:user) { create(:user, password: password) }

      let(:password) { Faker::Internet.password }

      context 'with valid credentials' do
        context 'using #login' do
          it 'returns the matching user' do
            expect(described_class.authenticate(user.login, password))
              .to eq(user)
          end

          it 'is not case-sensitive' do
            expect(described_class.authenticate(user.login.upcase, password))
              .to eq(user)
          end
        end

        context 'using #email' do
          it 'returns the matching user' do
            expect(described_class.authenticate(user.email, password))
              .to eq(user)
          end

          it 'is not case-sensitive' do
            expect(described_class.authenticate(user.email.upcase, password))
              .to eq(user)
          end
        end

        context 'but exceeding failed login limit' do
          before { user.update(login_failed: 999) }

          it 'returns nil' do
            expect(described_class.authenticate(user.login, password))
              .to be(nil)
          end
        end

        context 'when previous login was' do
          context 'never' do
            it 'updates #last_login and #updated_at' do
              expect { described_class.authenticate(user.login, password) }
                .to change { user.reload.last_login }
                .and change { user.reload.updated_at }
            end
          end

          context 'less than 10 minutes ago' do
            before do
              described_class.authenticate(user.login, password)
              travel 9.minutes
            end

            it 'does not update #last_login and #updated_at' do
              expect { described_class.authenticate(user.login, password) }
                .to not_change { user.reload.last_login }
                .and not_change { user.reload.updated_at }
            end
          end

          context 'more than 10 minutes ago' do
            before do
              described_class.authenticate(user.login, password)
              travel 11.minutes
            end

            it 'updates #last_login and #updated_at' do
              expect { described_class.authenticate(user.login, password) }
                .to change { user.reload.last_login }
                .and change { user.reload.updated_at }
            end
          end
        end
      end

      context 'with valid user and invalid password' do
        it 'increments failed login count' do
          expect(described_class).to receive(:sleep).with(1)
          expect { described_class.authenticate(user.login, password.next) }
            .to change { user.reload.login_failed }.by(1)
        end

        it 'returns nil' do
          expect(described_class).to receive(:sleep).with(1)
          expect(described_class.authenticate(user.login, password.next)).to be(nil)
        end
      end

      context 'with inactive user’s login' do
        before { user.update(active: false) }

        it 'returns nil' do
          expect(described_class.authenticate(user.login, password)).to be(nil)
        end
      end

      context 'with non-existent user login' do
        it 'returns nil' do
          expect(described_class.authenticate('john.doe', password)).to be(nil)
        end
      end

      context 'with empty login string' do
        it 'returns nil' do
          expect(described_class.authenticate('', password)).to be(nil)
        end
      end

      context 'with empty password string' do
        it 'returns nil' do
          expect(described_class.authenticate(user.login, '')).to be(nil)
        end
      end

      context 'with empty password string when the stored password is an empty string' do
        before { user.update_column(:password, '') }

        context 'when password is an empty string' do
          it 'returns nil' do
            expect(described_class.authenticate(user.login, '')).to be(nil)
          end
        end

        context 'when password is nil' do
          it 'returns nil' do
            expect(described_class.authenticate(user.login, nil)).to be(nil)
          end
        end
      end

      context 'with empty password string when the stored hash represents an empty string' do
        before { user.update(password: PasswordHash.crypt('')) }

        context 'when password is an empty string' do
          it 'returns nil' do
            expect(described_class.authenticate(user.login, '')).to be(nil)
          end
        end

        context 'when password is nil' do
          it 'returns nil' do
            expect(described_class.authenticate(user.login, nil)).to be(nil)
          end
        end
      end
    end

    describe '.identify' do
      it 'returns users by given login' do
        expect(described_class.identify(user.login)).to eq(user)
      end

      it 'returns users by given email' do
        expect(described_class.identify(user.email)).to eq(user)
      end
    end
  end

  describe 'Instance methods:' do
    describe '#max_login_failed?' do
      it { is_expected.to respond_to(:max_login_failed?) }

      context 'with "password_max_login_failed" setting' do
        before do
          Setting.set('password_max_login_failed', 5)
          user.update(login_failed: 5)
        end

        it 'returns true once user’s #login_failed count exceeds the setting' do
          expect { user.update(login_failed: 6) }
            .to change(user, :max_login_failed?).to(true)
        end
      end

      context 'without password_max_login_failed setting' do
        before do
          Setting.set('password_max_login_failed', nil)
          user.update(login_failed: 0)
        end

        it 'defaults to 0' do
          expect { user.update(login_failed: 1) }
            .to change(user, :max_login_failed?).to(true)
        end
      end
    end

    describe '#out_of_office?' do
      context 'without any out_of_office_* attributes set' do
        it 'returns false' do
          expect(agent.out_of_office?).to be(false)
        end
      end

      context 'with valid #out_of_office_* attributes' do
        before do
          agent.update(
            out_of_office_start_at:       Time.current.yesterday,
            out_of_office_end_at:         Time.current.tomorrow,
            out_of_office_replacement_id: 1
          )
        end

        context 'but #out_of_office: false' do
          before { agent.update(out_of_office: false) }

          it 'returns false' do
            expect(agent.out_of_office?).to be(false)
          end
        end

        context 'and #out_of_office: true' do
          before { agent.update(out_of_office: true) }

          it 'returns true' do
            expect(agent.out_of_office?).to be(true)
          end

          context 'after the #out_of_office_end_at time has passed' do
            before { travel 2.days  }

            it 'returns false (even though #out_of_office has not changed)' do
              expect(agent.out_of_office).to be(true)
              expect(agent.out_of_office?).to be(false)
            end
          end
        end
      end
    end

    describe '#out_of_office_agent' do
      it { is_expected.to respond_to(:out_of_office_agent) }

      context 'when user has no designated substitute' do
        it 'returns nil' do
          expect(user.out_of_office_agent).to be(nil)
        end
      end

      context 'when user has designated substitute' do
        subject(:user) do
          create(:user,
                 out_of_office:                out_of_office,
                 out_of_office_start_at:       Time.zone.yesterday,
                 out_of_office_end_at:         Time.zone.tomorrow,
                 out_of_office_replacement_id: substitute.id,)
        end

        let(:substitute) { create(:user) }

        context 'but is not out of office' do
          let(:out_of_office) { false }

          it 'returns nil' do
            expect(user.out_of_office_agent).to be(nil)
          end
        end

        context 'and is out of office' do
          let(:out_of_office) { true }

          it 'returns the designated substitute' do
            expect(user.out_of_office_agent).to eq(substitute)
          end
        end
      end
    end

    describe '#out_of_office_agent_of' do
      context 'when no other agents are out-of-office' do
        it 'returns an empty ActiveRecord::Relation' do
          expect(agent.out_of_office_agent_of)
            .to be_an(ActiveRecord::Relation)
            .and be_empty
        end
      end

      context 'when designated as the substitute' do
        let!(:agent_on_holiday) do
          create(
            :agent_user,
            out_of_office_start_at:       Time.current.yesterday,
            out_of_office_end_at:         Time.current.tomorrow,
            out_of_office_replacement_id: agent.id,
            out_of_office:                out_of_office
          )
        end

        context 'of an in-office agent' do
          let(:out_of_office) { false }

          it 'returns an empty ActiveRecord::Relation' do
            expect(agent.out_of_office_agent_of)
              .to be_an(ActiveRecord::Relation)
              .and be_empty
          end
        end

        context 'of an out-of-office agent' do
          let(:out_of_office) { true }

          it 'returns an ActiveRecord::Relation including that agent' do
            expect(agent.out_of_office_agent_of)
              .to match_array([agent_on_holiday])
          end
        end
      end
    end

    describe '#by_reset_token' do
      subject(:user) { token.user }

      let(:token) { create(:token_password_reset) }

      context 'with a valid token' do
        it 'returns the matching user' do
          expect(described_class.by_reset_token(token.name)).to eq(user)
        end
      end

      context 'with an invalid token' do
        it 'returns nil' do
          expect(described_class.by_reset_token('not-existing')).to be(nil)
        end
      end
    end

    describe '#password_reset_via_token' do
      subject(:user) { token.user }

      let!(:token) { create(:token_password_reset) }

      it 'changes the password of the token user and destroys the token' do
        expect { described_class.password_reset_via_token(token.name, Faker::Internet.password) }
          .to change { user.reload.password }
          .and change(Token, :count).by(-1)
      end
    end

    describe '#access?' do
      context 'when an admin' do
        subject(:user) { create(:user, roles: [partial_admin_role]) }

        context 'with "admin.user" privileges' do
          let(:partial_admin_role) do
            create(:role).tap { |role| role.permission_grant('admin.user') }
          end

          context 'wants to read, change, or delete any user' do
            it 'returns true' do
              expect(admin.access?(user, 'read')).to be(true)
              expect(admin.access?(user, 'change')).to be(true)
              expect(admin.access?(user, 'delete')).to be(true)
              expect(agent.access?(user, 'read')).to be(true)
              expect(agent.access?(user, 'change')).to be(true)
              expect(agent.access?(user, 'delete')).to be(true)
              expect(customer.access?(user, 'read')).to be(true)
              expect(customer.access?(user, 'change')).to be(true)
              expect(customer.access?(user, 'delete')).to be(true)
              expect(user.access?(user, 'read')).to be(true)
              expect(user.access?(user, 'change')).to be(true)
              expect(user.access?(user, 'delete')).to be(true)
            end
          end
        end

        context 'without "admin.user" privileges' do
          let(:partial_admin_role) do
            create(:role).tap { |role| role.permission_grant('admin.tag') }
          end

          context 'wants to read any user' do
            it 'returns true' do
              expect(admin.access?(user, 'read')).to be(true)
              expect(agent.access?(user, 'read')).to be(true)
              expect(customer.access?(user, 'read')).to be(true)
              expect(user.access?(user, 'read')).to be(true)
            end
          end

          context 'wants to change or delete any user' do
            it 'returns false' do
              expect(admin.access?(user, 'change')).to be(false)
              expect(admin.access?(user, 'delete')).to be(false)
              expect(agent.access?(user, 'change')).to be(false)
              expect(agent.access?(user, 'delete')).to be(false)
              expect(customer.access?(user, 'change')).to be(false)
              expect(customer.access?(user, 'delete')).to be(false)
              expect(user.access?(user, 'change')).to be(false)
              expect(user.access?(user, 'delete')).to be(false)
            end
          end
        end
      end

      context 'when an agent' do
        subject(:user) { create(:agent_user) }

        context 'wants to read any user' do
          it 'returns true' do
            expect(admin.access?(user, 'read')).to be(true)
            expect(agent.access?(user, 'read')).to be(true)
            expect(customer.access?(user, 'read')).to be(true)
            expect(user.access?(user, 'read')).to be(true)
          end
        end

        context 'wants to change' do
          context 'any admin or agent' do
            it 'returns false' do
              expect(admin.access?(user, 'change')).to be(false)
              expect(agent.access?(user, 'change')).to be(false)
              expect(user.access?(user, 'change')).to be(false)
            end
          end

          context 'any customer' do
            it 'returns true' do
              expect(customer.access?(user, 'change')).to be(true)
            end
          end
        end

        context 'wants to delete any user' do
          it 'returns false' do
            expect(admin.access?(user, 'delete')).to be(false)
            expect(agent.access?(user, 'delete')).to be(false)
            expect(customer.access?(user, 'delete')).to be(false)
            expect(user.access?(user, 'delete')).to be(false)
          end
        end
      end

      context 'when a customer' do
        subject(:user) { create(:customer_user, :with_org) }

        let(:colleague) { create(:customer_user, organization: user.organization) }

        context 'wants to read' do
          context 'any admin, agent, or customer from a different organization' do
            it 'returns false' do
              expect(admin.access?(user, 'read')).to be(false)
              expect(agent.access?(user, 'read')).to be(false)
              expect(customer.access?(user, 'read')).to be(false)
            end
          end

          context 'any customer from the same organization' do
            it 'returns true' do
              expect(user.access?(user, 'read')).to be(true)
              expect(colleague.access?(user, 'read')).to be(true)
            end
          end
        end

        context 'wants to change or delete any user' do
          it 'returns false' do
            expect(admin.access?(user, 'change')).to be(false)
            expect(admin.access?(user, 'delete')).to be(false)
            expect(agent.access?(user, 'change')).to be(false)
            expect(agent.access?(user, 'delete')).to be(false)
            expect(customer.access?(user, 'change')).to be(false)
            expect(customer.access?(user, 'delete')).to be(false)
            expect(colleague.access?(user, 'change')).to be(false)
            expect(colleague.access?(user, 'delete')).to be(false)
            expect(user.access?(user, 'change')).to be(false)
            expect(user.access?(user, 'delete')).to be(false)
          end
        end
      end
    end

    describe '#permissions?' do
      subject(:user) { create(:user, roles: [role]) }

      let(:role) { create(:role, permissions: [permission]) }
      let(:permission) { create(:permission, name: permission_name) }

      context 'with privileges for a root permission (e.g., "foo", not "foo.bar")' do
        let(:permission_name) { 'foo' }

        context 'when given that exact permission' do
          it 'returns true' do
            expect(user.permissions?('foo')).to be(true)
          end
        end

        context 'when given a sub-permission (i.e., child permission)' do
          let(:subpermission) { create(:permission, name: 'foo.bar') }

          context 'that exists' do
            before { subpermission }

            it 'returns true' do
              expect(user.permissions?('foo.bar')).to be(true)
            end
          end

          context 'that is inactive' do
            before { subpermission.update(active: false) }

            it 'returns false' do
              expect(user.permissions?('foo.bar')).to be(false)
            end
          end

          context 'that does not exist' do
            it 'returns true' do
              expect(user.permissions?('foo.bar')).to be(true)
            end
          end
        end

        context 'when given a glob' do
          context 'matching that permission' do
            it 'returns true' do
              expect(user.permissions?('foo.*')).to be(true)
            end
          end

          context 'NOT matching that permission' do
            it 'returns false' do
              expect(user.permissions?('bar.*')).to be(false)
            end
          end
        end
      end

      context 'with privileges for a sub-permission (e.g., "foo.bar", not "foo")' do
        let(:permission_name) { 'foo.bar' }

        context 'when given that exact sub-permission' do
          it 'returns true' do
            expect(user.permissions?('foo.bar')).to be(true)
          end

          context 'but the permission is inactive' do
            before { permission.update(active: false) }

            it 'returns false' do
              expect(user.permissions?('foo.bar')).to be(false)
            end
          end
        end

        context 'when given a sibling sub-permission' do
          let(:sibling_permission) { create(:permission, name: 'foo.baz') }

          context 'that exists' do
            before { sibling_permission }

            it 'returns false' do
              expect(user.permissions?('foo.baz')).to be(false)
            end
          end

          context 'that does not exist' do
            it 'returns false' do
              expect(user.permissions?('foo.baz')).to be(false)
            end
          end
        end

        context 'when given the parent permission' do
          it 'returns false' do
            expect(user.permissions?('foo')).to be(false)
          end
        end

        context 'when given a glob' do
          context 'matching that sub-permission' do
            it 'returns true' do
              expect(user.permissions?('foo.*')).to be(true)
            end

            context 'but the permission is inactive' do
              before { permission.update(active: false) }

              it 'returns false' do
                expect(user.permissions?('foo.bar')).to be(false)
              end
            end
          end

          context 'NOT matching that sub-permission' do
            it 'returns false' do
              expect(user.permissions?('bar.*')).to be(false)
            end
          end
        end
      end
    end

    describe '#permissions_with_child_ids' do
      context 'with privileges for a root permission (e.g., "foo", not "foo.bar")' do
        subject(:user) { create(:user, roles: [role]) }

        let(:role) { create(:role, permissions: [permission]) }
        let!(:permission) { create(:permission, name: 'foo') }
        let!(:child_permission) { create(:permission, name: 'foo.bar') }
        let!(:inactive_child_permission) { create(:permission, name: 'foo.baz', active: false) }

        it 'includes the IDs of user’s explicit permissions' do
          expect(user.permissions_with_child_ids)
            .to include(permission.id)
        end

        it 'includes the IDs of user’s active sub-permissions' do
          expect(user.permissions_with_child_ids)
            .to include(child_permission.id)
            .and not_include(inactive_child_permission.id)
        end
      end
    end

    describe '#locale' do
      subject(:user) { create(:user, preferences: preferences) }

      context 'with no #preferences[:locale]' do
        let(:preferences) { {} }

        before { Setting.set('locale_default', 'foo') }

        it 'returns the system-wide default locale' do
          expect(user.locale).to eq('foo')
        end
      end

      context 'with a #preferences[:locale]' do
        let(:preferences) { { locale: 'bar' } }

        it 'returns the user’s configured locale' do
          expect(user.locale).to eq('bar')
        end
      end
    end
  end

  describe 'Attributes:' do
    describe '#out_of_office' do
      context 'with #out_of_office_start_at: nil' do
        before { agent.update(out_of_office_start_at: nil, out_of_office_end_at: Time.current) }

        it 'cannot be set to true' do
          expect { agent.update(out_of_office: true) }
            .to raise_error(Exceptions::UnprocessableEntity)
        end
      end

      context 'with #out_of_office_end_at: nil' do
        before { agent.update(out_of_office_start_at: Time.current, out_of_office_end_at: nil) }

        it 'cannot be set to true' do
          expect { agent.update(out_of_office: true) }
            .to raise_error(Exceptions::UnprocessableEntity)
        end
      end

      context 'when #out_of_office_start_at is AFTER #out_of_office_end_at' do
        before { agent.update(out_of_office_start_at: Time.current.tomorrow, out_of_office_end_at: Time.current.next_month) }

        it 'cannot be set to true' do
          expect { agent.update(out_of_office: true) }
            .to raise_error(Exceptions::UnprocessableEntity)
        end
      end

      context 'when #out_of_office_start_at is AFTER Time.current' do
        before { agent.update(out_of_office_start_at: Time.current.tomorrow, out_of_office_end_at: Time.current.yesterday) }

        it 'cannot be set to true' do
          expect { agent.update(out_of_office: true) }
            .to raise_error(Exceptions::UnprocessableEntity)
        end
      end

      context 'when #out_of_office_end_at is BEFORE Time.current' do
        before { agent.update(out_of_office_start_at: Time.current.last_month, out_of_office_end_at: Time.current.yesterday) }

        it 'cannot be set to true' do
          expect { agent.update(out_of_office: true) }
            .to raise_error(Exceptions::UnprocessableEntity)
        end
      end
    end

    describe '#out_of_office_replacement_id' do
      it 'cannot be set to invalid user ID' do
        expect { agent.update(out_of_office_replacement_id: described_class.pluck(:id).max.next) }
          .to raise_error(ActiveRecord::InvalidForeignKey)
      end

      it 'can be set to a valid user ID' do
        expect { agent.update(out_of_office_replacement_id: 1) }
          .not_to raise_error
      end
    end

    describe '#login_failed' do
      before { user.update(login_failed: 1) }

      it 'is reset to 0 when password is updated' do
        expect { user.update(password: Faker::Internet.password) }
          .to change(user, :login_failed).to(0)
      end
    end

    describe '#password' do
      let(:password) { Faker::Internet.password }

      context 'when set to plaintext password' do
        it 'hashes password before saving to DB' do
          user.password = password

          expect { user.save }
            .to change { PasswordHash.crypted?(user.password) }
        end
      end

      context 'for existing user records' do
        context 'when changed to empty string' do
          before { user.update(password: password) }

          it 'keeps previous password' do

            expect { user.update!(password: '') }
              .not_to change(user, :password)
          end
        end

        context 'when changed to nil' do
          before { user.update(password: password) }

          it 'keeps previous password' do
            expect { user.update!(password: nil) }
              .not_to change(user, :password)
          end
        end
      end

      context 'for new user records' do
        context 'when passed as an empty string' do
          let(:another_user) { create(:user, password: '') }

          it 'sets password to nil' do
            expect(another_user.password).to eq(nil)
          end
        end

        context 'when passed as nil' do
          let(:another_user) { create(:user, password: nil) }

          it 'sets password to nil' do
            expect(another_user.password).to eq(nil)
          end
        end
      end

      context 'when set to SHA2 digest (to facilitate OTRS imports)' do
        it 'does not re-hash before saving' do
          user.password = "{sha2}#{Digest::SHA2.hexdigest(password)}"

          expect { user.save }.not_to change(user, :password)
        end
      end

      context 'when set to Argon2 digest' do
        it 'does not re-hash before saving' do
          user.password = PasswordHash.crypt(password)

          expect { user.save }.not_to change(user, :password)
        end
      end

      context 'when creating two users with the same password' do
        before { user.update(password: password) }

        let(:another_user) { create(:user, password: password) }

        it 'does not generate the same password hash' do
          expect(user.password).not_to eq(another_user.password)
        end
      end
    end

    describe '#phone' do
      subject(:user) { create(:user, phone: orig_number) }

      context 'when included on create' do
        let(:orig_number) { '1234567890' }

        it 'adds corresponding CallerId record' do
          expect { user }
            .to change { Cti::CallerId.where(caller_id: orig_number).count }.by(1)
        end
      end

      context 'when added on update' do
        let(:orig_number) { nil }
        let(:new_number) { '1234567890' }

        before { user } # create user

        it 'adds corresponding CallerId record' do
          expect { user.update(phone: new_number) }
            .to change { Cti::CallerId.where(caller_id: new_number).count }.by(1)
        end
      end

      context 'when falsely added on update (change: [nil, ""])' do
        let(:orig_number) { nil }
        let(:new_number)  { '' }

        before { user } # create user

        it 'does not attempt to update CallerId record' do
          allow(Cti::CallerId).to receive(:build).with(any_args)

          expect(Cti::CallerId.where(object: 'User', o_id: user.id).count)
            .to eq(0)

          expect { user.update(phone: new_number) }
            .to change { Cti::CallerId.where(object: 'User', o_id: user.id).count }.by(0)

          expect(Cti::CallerId).not_to have_received(:build)
        end
      end

      context 'when removed on update' do
        let(:orig_number) { '1234567890' }
        let(:new_number) { nil }

        before { user } # create user

        it 'removes corresponding CallerId record' do
          expect { user.update(phone: nil) }
            .to change { Cti::CallerId.where(caller_id: orig_number).count }.by(-1)
        end
      end

      context 'when changed on update' do
        let(:orig_number) { '1234567890' }
        let(:new_number)  { orig_number.next }

        before { user } # create user

        it 'replaces CallerId record' do
          expect { user.update(phone: new_number) }
            .to change { Cti::CallerId.where(caller_id: orig_number).count }.by(-1)
            .and change { Cti::CallerId.where(caller_id: new_number).count }.by(1)
        end
      end
    end

    describe '#preferences' do
      describe '"mail_delivery_failed{,_data}" keys' do
        before do
          user.update(
            preferences: {
              mail_delivery_failed:      true,
              mail_delivery_failed_data: Time.current
            }
          )
        end

        it 'deletes "mail_delivery_failed"' do
          expect { user.update(email: Faker::Internet.email) }
            .to change { user.preferences.key?(:mail_delivery_failed) }.to(false)
        end

        it 'leaves "mail_delivery_failed_data" untouched' do
          expect { user.update(email: Faker::Internet.email) }
            .to not_change { user.preferences[:mail_delivery_failed_data] }
        end
      end
    end
  end

  describe 'Associations:' do
    describe '#organization' do
      describe 'email domain-based assignment' do
        subject(:user) { build(:user) }

        context 'when not set on creation' do
          before { user.assign_attributes(organization: nil) }

          context 'and #email domain matches an existing Organization#domain' do
            before { user.assign_attributes(email: 'user@example.com') }

            let(:organization) { create(:organization, domain: 'example.com') }

            context 'and Organization#domain_assignment is false (default)' do
              before { organization.update(domain_assignment: false) }

              it 'remains nil' do
                expect { user.save }.not_to change(user, :organization)
              end
            end

            context 'and Organization#domain_assignment is true' do
              before { organization.update(domain_assignment: true) }

              it 'is automatically set to matching Organization' do
                expect { user.save }
                  .to change(user, :organization).to(organization)
              end
            end
          end

          context 'and #email domain doesn’t match any Organization#domain' do
            before { user.assign_attributes(email: 'user@example.net') }

            let(:organization) { create(:organization, domain: 'example.com') }

            context 'and Organization#domain_assignment is true' do
              before { organization.update(domain_assignment: true) }

              it 'remains nil' do
                expect { user.save }.not_to change(user, :organization)
              end
            end
          end
        end

        context 'when set on creation' do
          before { user.assign_attributes(organization: specified_organization) }

          let(:specified_organization) { create(:organization, domain: 'example.net') }

          context 'and #email domain matches a DIFFERENT Organization#domain' do
            before { user.assign_attributes(email: 'user@example.com') }

            let!(:matching_organization) { create(:organization, domain: 'example.com') }

            context 'and Organization#domain_assignment is true' do
              before { matching_organization.update(domain_assignment: true) }

              it 'is NOT automatically set to matching Organization' do
                expect { user.save }
                  .not_to change(user, :organization).from(specified_organization)
              end
            end
          end
        end
      end
    end
  end

  describe 'Callbacks, Observers, & Async Transactions -' do
    describe 'System-wide agent limit checks:' do
      let(:agent_role) { Role.lookup(name: 'Agent') }
      let(:admin_role) { Role.lookup(name: 'Admin') }
      let(:current_agents) { described_class.with_permissions('ticket.agent') }

      describe '#validate_agent_limit_by_role' do
        context 'for Integer value of system_agent_limit' do
          context 'before exceeding the agent limit' do
            before { Setting.set('system_agent_limit', current_agents.count + 1) }

            it 'grants agent creation' do
              expect { create(:agent_user) }
                .to change(current_agents, :count).by(1)
            end

            it 'grants role change' do
              future_agent = create(:customer_user)

              expect { future_agent.roles = [agent_role] }
                .to change(current_agents, :count).by(1)
            end

            describe 'role updates' do
              let(:agent) { create(:agent_user) }

              it 'grants update by instances' do
                expect { agent.roles = [admin_role, agent_role] }
                  .not_to raise_error
              end

              it 'grants update by id (Integer)' do
                expect { agent.role_ids = [admin_role.id, agent_role.id] }
                  .not_to raise_error
              end

              it 'grants update by id (String)' do
                expect { agent.role_ids = [admin_role.id.to_s, agent_role.id.to_s] }
                  .not_to raise_error
              end
            end
          end

          context 'when exceeding the agent limit' do
            it 'creation of new agents' do
              Setting.set('system_agent_limit', current_agents.count + 2)

              create_list(:agent_user, 2)

              expect { create(:agent_user) }
                .to raise_error(Exceptions::UnprocessableEntity)
                .and change(current_agents, :count).by(0)
            end

            it 'prevents role change' do
              Setting.set('system_agent_limit', current_agents.count)

              future_agent = create(:customer_user)

              expect { future_agent.roles = [agent_role] }
                .to raise_error(Exceptions::UnprocessableEntity)
                .and change(current_agents, :count).by(0)
            end
          end
        end

        context 'for String value of system_agent_limit' do
          context 'before exceeding the agent limit' do
            before { Setting.set('system_agent_limit', (current_agents.count + 1).to_s) }

            it 'grants agent creation' do
              expect { create(:agent_user) }
                .to change(current_agents, :count).by(1)
            end

            it 'grants role change' do
              future_agent = create(:customer_user)

              expect { future_agent.roles = [agent_role] }
                .to change(current_agents, :count).by(1)
            end

            describe 'role updates' do
              let(:agent) { create(:agent_user) }

              it 'grants update by instances' do
                expect { agent.roles = [admin_role, agent_role] }
                  .not_to raise_error
              end

              it 'grants update by id (Integer)' do
                expect { agent.role_ids = [admin_role.id, agent_role.id] }
                  .not_to raise_error
              end

              it 'grants update by id (String)' do
                expect { agent.role_ids = [admin_role.id.to_s, agent_role.id.to_s] }
                  .not_to raise_error
              end
            end
          end

          context 'when exceeding the agent limit' do
            it 'creation of new agents' do
              Setting.set('system_agent_limit', (current_agents.count + 2).to_s)

              create_list(:agent_user, 2)

              expect { create(:agent_user) }
                .to raise_error(Exceptions::UnprocessableEntity)
                .and change(current_agents, :count).by(0)
            end

            it 'prevents role change' do
              Setting.set('system_agent_limit', current_agents.count.to_s)

              future_agent = create(:customer_user)

              expect { future_agent.roles = [agent_role] }
                .to raise_error(Exceptions::UnprocessableEntity)
                .and change(current_agents, :count).by(0)
            end
          end
        end
      end

      describe '#validate_agent_limit_by_attributes' do
        context 'for Integer value of system_agent_limit' do
          before { Setting.set('system_agent_limit', current_agents.count) }

          context 'when exceeding the agent limit' do
            it 'prevents re-activation of agents' do
              inactive_agent = create(:agent_user, active: false)

              expect { inactive_agent.update!(active: true) }
                .to raise_error(Exceptions::UnprocessableEntity)
                .and change(current_agents, :count).by(0)
            end
          end
        end

        context 'for String value of system_agent_limit' do
          before { Setting.set('system_agent_limit', current_agents.count.to_s) }

          context 'when exceeding the agent limit' do
            it 'prevents re-activation of agents' do
              inactive_agent = create(:agent_user, active: false)

              expect { inactive_agent.update!(active: true) }
                .to raise_error(Exceptions::UnprocessableEntity)
                .and change(current_agents, :count).by(0)
            end
          end
        end
      end
    end

    describe 'Touching associations on update:' do
      subject(:user) { create(:customer_user, organization: organization) }

      let(:organization) { create(:organization) }
      let(:other_customer) { create(:customer_user) }

      context 'when basic attributes are updated' do
        it 'touches its organization' do
          expect { user.update(firstname: 'foo') }
            .to change { organization.reload.updated_at }
        end
      end

      context 'when organization has 100+ other members' do
        let!(:other_members) { create_list(:user, 100, organization: organization) }

        context 'and basic attributes are updated' do
          it 'does not touch its organization' do
            expect { user.update(firstname: 'foo') }
              .to not_change { organization.reload.updated_at }
          end
        end
      end
    end

    describe 'Cti::CallerId syncing:' do
      context 'with a #phone attribute' do
        subject(:user) { build(:user, phone: '1234567890') }

        it 'adds CallerId record on creation (via Cti::CallerId.build)' do
          expect(Cti::CallerId).to receive(:build).with(user)

          user.save
        end

        it 'updates CallerId record on touch/update (via Cti::CallerId.build)' do
          user.save

          expect(Cti::CallerId).to receive(:build).with(user)

          user.touch
        end

        it 'destroys CallerId record on deletion' do
          user.save

          expect { user.destroy }
            .to change { Cti::CallerId.count }.by(-1)
        end
      end
    end

    describe 'Cti::Log syncing:' do
      context 'with existing Log records' do
        context 'for incoming calls from an unknown number' do
          let!(:log) { create(:'cti/log', :with_preferences, from: '1234567890', direction: 'in') }

          context 'when creating a new user with that number' do
            subject(:user) { build(:user, phone: log.from) }

            it 'populates #preferences[:from] hash in all associated Log records (in a bg job)' do
              expect do
                user.save
                Observer::Transaction.commit
                Scheduler.worker(true)
              end.to change { log.reload.preferences[:from]&.first }
                .to(hash_including('caller_id' => user.phone))
            end
          end

          context 'when updating a user with that number' do
            subject(:user) { create(:user) }

            it 'populates #preferences[:from] hash in all associated Log records (in a bg job)' do
              expect do
                user.update(phone: log.from)
                Observer::Transaction.commit
                Scheduler.worker(true)
              end.to change { log.reload.preferences[:from]&.first }
                .to(hash_including('object' => 'User', 'o_id' => user.id))
            end
          end

          context 'when creating a new user with an empty number' do
            subject(:user) { build(:user, phone: '') }

            it 'does not modify any Log records' do
              expect do
                user.save
                Observer::Transaction.commit
                Scheduler.worker(true)
              end.not_to change { log.reload.attributes }
            end
          end

          context 'when creating a new user with no number' do
            subject(:user) { build(:user, phone: nil) }

            it 'does not modify any Log records' do
              expect do
                user.save
                Observer::Transaction.commit
                Scheduler.worker(true)
              end.not_to change { log.reload.attributes }
            end
          end
        end

        context 'for incoming calls from the given user' do
          subject(:user) { create(:user, phone: '1234567890') }

          let!(:logs) { create_list(:'cti/log', 5, :with_preferences, from: user.phone, direction: 'in') }

          context 'when updating #phone attribute' do
            context 'to another number' do
              it 'empties #preferences[:from] hash in all associated Log records (in a bg job)' do
                expect do
                  user.update(phone: '0123456789')
                  Observer::Transaction.commit
                  Scheduler.worker(true)
                end.to change { logs.map(&:reload).map(&:preferences) }
                  .to(Array.new(5) { {} })
              end
            end

            context 'to an empty string' do
              it 'empties #preferences[:from] hash in all associated Log records (in a bg job)' do
                expect do
                  user.update(phone: '')
                  Observer::Transaction.commit
                  Scheduler.worker(true)
                end.to change { logs.map(&:reload).map(&:preferences) }
                  .to(Array.new(5) { {} })
              end
            end

            context 'to nil' do
              it 'empties #preferences[:from] hash in all associated Log records (in a bg job)' do
                expect do
                  user.update(phone: nil)
                  Observer::Transaction.commit
                  Scheduler.worker(true)
                end.to change { logs.map(&:reload).map(&:preferences) }
                  .to(Array.new(5) { {} })
              end
            end
          end

          context 'when updating attributes other than #phone' do
            it 'does not modify any Log records' do
              expect do
                user.update(mobile: '2345678901')
                Observer::Transaction.commit
                Scheduler.worker(true)
              end.not_to change { logs.map(&:reload).map(&:attributes) }
            end
          end
        end
      end
    end
  end

end
