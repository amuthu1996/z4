require 'rails_helper'
require 'models/concerns/checks_kb_client_notification_examples'
require 'models/contexts/factory_context'

RSpec.describe KnowledgeBase::Answer, type: :model, current_user_id: 1 do
  subject!(:kb_answer) { create(:knowledge_base_answer) }

  include_context 'factory'

  it_behaves_like 'ChecksKbClientNotification'

  it { is_expected.not_to validate_presence_of(:category_id) }
  it { is_expected.to belong_to(:category) }
end
