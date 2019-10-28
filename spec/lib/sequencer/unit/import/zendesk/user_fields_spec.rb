require 'rails_helper'
require 'lib/sequencer/unit/import/zendesk/sub_sequence/base_examples'

RSpec.describe Sequencer::Unit::Import::Zendesk::UserFields, sequencer: :unit do
  it_behaves_like 'Sequencer::Unit::Import::Zendesk::SubSequence::Base'
end
