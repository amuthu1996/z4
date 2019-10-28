require 'rails_helper'

RSpec.describe Sequencer::Unit::Import::Common::Mapping::FlatKeys, sequencer: :unit do

  it 'raises an error if mapping method is not implemented' do
    expect do
      process(
        resource: {
          remote_attribute: 'value',
        }
      )
    end.to raise_error(RuntimeError, /mapping/)
  end

  it 'maps flat key structures' do

    parameters = {
      resource: {
        remote_attribute: 'value',
      }
    }

    mapping = {
      remote_attribute: :local_attribute
    }

    provided = process(parameters) do |instance|
      expect(instance).to receive(:mapping).and_return(mapping)
    end

    expect(provided).to eq(
      mapped: {
        'local_attribute' => 'value',
      }
    )
    expect(provided[:mapped]).to be_a(ActiveSupport::HashWithIndifferentAccess)
  end
end
