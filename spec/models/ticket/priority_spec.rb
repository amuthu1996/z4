require 'rails_helper'
require 'models/application_model_examples'
require 'models/concerns/can_be_imported_examples'

RSpec.describe Ticket::Priority, type: :model do
  it_behaves_like 'ApplicationModel'
  it_behaves_like 'CanBeImported'

  describe 'Default state' do
    describe 'of whole table:' do
      it 'has exactly one default record' do
        expect(described_class.where(default_create: true)).to be_one
      end
    end
  end

  describe 'attributes' do
    describe '#default_create' do
      it 'cannot be true for more than one record at a time' do
        expect { create(:'ticket/priority', default_create: true) }
          .to change { described_class.find_by(default_create: true).id }
          .and change { described_class.where(default_create: true).count }.by(0)
      end

      it 'cannot be false for all records' do
        create(:'ticket/priority', default_create: true)

        expect { described_class.find_by(default_create: true).destroy }
          .to change { described_class.find_by(default_create: true).id }
          .and change { described_class.where(default_create: true).count }.by(0)
      end

      it 'is not automatically set to the last-created record' do
        expect { create(:'ticket/priority') }
          .not_to change { described_class.find_by(default_create: true).id }
      end
    end
  end
end
