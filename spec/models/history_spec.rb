require 'rails_helper'
require 'models/application_model_examples'
require 'models/concerns/can_be_imported_examples'

RSpec.describe History, type: :model do
  it_behaves_like 'ApplicationModel', can_assets: { own_attributes: false }
  it_behaves_like 'CanBeImported'

  describe '.list' do
    context 'when given an object with no histories' do
      let!(:object) { create(:'cti/log') }

      it 'returns an empty array' do
        expect(described_class.list(object.class.name, object.id))
          .to be_an(Array).and be_empty
      end
    end

    context 'when given an object with histories' do
      context 'and called without "related_history_object" argument' do
        let!(:object) { create(:user) }

        before { object.update(email: 'foo@example.com') }

        context 'or "assets" flag' do
          let(:list) { described_class.list(object.class.name, object.id) }

          it 'returns an array of attribute hashes for those histories' do
            expect(list).to match_array(
              [
                hash_including(
                  'o_id'   => object.id,
                ),
                hash_including(
                  'o_id'     => object.id,
                  'value_to' => 'foo@example.com',
                )
              ]
            )
          end

          it 'replaces *_id attributes with the corresponding association #name' do
            expect(list.first)
              .to not_include('history_object_id', 'history_type_id')
              .and include(
                'object' => object.class.name,
                'type'   => 'created',
              )

            expect(list.second)
              .to not_include('history_object_id', 'history_type_id', 'history_attribute_id')
              .and include(
                'object'    => object.class.name,
                'type'      => 'updated',
                'attribute' => 'email',
              )
          end
        end

        context 'but with "assets" flag' do
          let(:list) { described_class.list(object.class.name, object.id, nil, true) }
          let(:matching_histories) do
            described_class.where(
              o_id:              object.id,
              history_object_id: History::Object.lookup(name: object.class.name).id
            )
          end

          it 'returns a hash including an array of history attribute hashes' do
            expect(list).to include(
              list: [
                hash_including(
                  'o_id'   => object.id,
                  'object' => object.class.name,
                  'type'   => 'created',
                ),
                hash_including(
                  'o_id'      => object.id,
                  'object'    => object.class.name,
                  'type'      => 'updated',
                  'attribute' => 'email',
                  'value_to'  => 'foo@example.com',
                )
              ]
            )
          end

          it 'returns a hash including each history record’s FE assets' do
            expect(list).to include(
              assets: matching_histories.reduce({}) { |assets, h| h.assets(assets) }
            )
          end
        end
      end

      context 'with "related_history_object" argument' do
        let!(:object) { related_object.ticket }
        let!(:related_object) { create(:ticket_article, internal: true) }  # MUST be internal, or else callbacks will create additional histories

        before { object.update(title: 'Lorem ipsum dolor') }

        context 'but no "assets" flag' do
          let(:list) { described_class.list(object.class.name, object.id, 'Ticket::Article') }

          it 'returns an array of attribute hashes for those histories' do
            expect(list).to match_array(
              [
                hash_including(
                  'o_id'   => object.id,
                ),
                hash_including(
                  'o_id'   => related_object.id,
                ),
                hash_including(
                  'o_id'     => object.id,
                  'value_to' => 'Lorem ipsum dolor',
                )
              ]
            )
          end

          it 'replaces *_id attributes with the corresponding association #name' do
            expect(list.first)
              .to not_include('history_object_id', 'history_type_id')
              .and include(
                'object' => object.class.name,
                'type'   => 'created',
              )

            expect(list.second)
              .to not_include('history_object_id', 'history_type_id')
              .and include(
                'object' => related_object.class.name,
                'type'   => 'created',
              )

            expect(list.third)
              .to not_include('history_object_id', 'history_type_id', 'history_attribute_id')
              .and include(
                'object'    => object.class.name,
                'type'      => 'updated',
                'attribute' => 'title',
              )
          end
        end

        context 'and "assets" flag' do
          let(:list) { described_class.list(object.class.name, object.id, 'Ticket::Article', true) }
          let(:matching_histories) do
            described_class.where(
              o_id:              object.id,
              history_object_id: History::Object.lookup(name: object.class.name).id
            ) + described_class.where(
              o_id:              related_object.id,
              history_object_id: History::Object.lookup(name: related_object.class.name).id
            )
          end

          it 'returns a hash including an array of history attribute hashes' do
            expect(list).to include(
              list: [
                hash_including(
                  'o_id'   => object.id,
                  'object' => object.class.name,
                  'type'   => 'created',
                ),
                hash_including(
                  'o_id'   => related_object.id,
                  'object' => related_object.class.name,
                  'type'   => 'created',
                ),
                hash_including(
                  'o_id'      => object.id,
                  'object'    => object.class.name,
                  'type'      => 'updated',
                  'attribute' => 'title',
                  'value_to'  => 'Lorem ipsum dolor',
                )
              ]
            )
          end

          it 'returns a hash including each history record’s FE assets' do
            expect(list).to include(
              assets: matching_histories.reduce({}) { |assets, h| h.assets(assets) }
            )
          end
        end
      end
    end

    context 'when given an object with histories' do
      context 'and called without "condition" argument' do
        let!(:object) { create(:user) }

        before do
          travel 3.days
          object.update(email: 'foo@example.com')
        end

        context 'or "assets" flag' do
          let(:list) { described_class.list(object.class.name, object.id, nil, nil, ['created_at > ?', [Time.zone.now - 2.days]]) }

          it 'returns an array of attribute hashes for those histories' do
            expect(list).to match_array(
              [
                hash_including(
                  'type'     => 'updated',
                  'o_id'     => object.id,
                  'value_to' => 'foo@example.com',
                )
              ]
            )
          end
        end
      end
    end
  end
end
