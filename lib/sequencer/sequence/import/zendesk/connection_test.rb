class Sequencer
  class Sequence
    module Import
      module Zendesk
        class ConnectionTest < Sequencer::Sequence::Base

          def self.expecting
            [:connected]
          end

          def self.sequence
            [
              'Zendesk::Client',
              'Zendesk::Connected',
            ]
          end
        end
      end
    end
  end
end
