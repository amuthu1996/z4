class Sequencer
  class Unit
    module Import
      module Common
        module Model
          class ResetPrimaryKeySequence < Sequencer::Unit::Base
            extend Forwardable

            uses :model_class

            delegate table_name: :model_class

            def process
              DbHelper.import_post(table_name)
            end
          end
        end
      end
    end
  end
end
