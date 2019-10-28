class Sequencer
  class Unit
    module Import
      module Zendesk
        module Ticket
          class Subject < Sequencer::Unit::Common::Provider::Named

            uses :resource

            private

            def subject
              resource.subject || resource.description || '-'
            end
          end
        end
      end
    end
  end
end
