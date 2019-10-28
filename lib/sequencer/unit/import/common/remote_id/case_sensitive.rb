class Sequencer
  class Unit
    module Import
      module Common
        module RemoteId
          class CaseSensitive < Sequencer::Unit::Base

            uses :remote_id
            provides :remote_id

            def process
              state.provide(:remote_id) do
                Digest::SHA2.hexdigest(state.use(:remote_id))
              end
            end
          end
        end
      end
    end
  end
end
