require 'rails_helper'
require 'models/concerns/has_group_relation_definition_examples'

RSpec.describe UserGroup do

  let!(:group_relation_instance) { create(:agent_user) }

  it_behaves_like 'HasGroupRelationDefinition'
end
