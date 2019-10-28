# this require is required (hehe) because of Rails autoloading
# which causes strange behavior not inheriting correctly
# from Import::OTRS::DynamicField
require_dependency 'import/zendesk/object_attribute/base'

module Import
  class Zendesk
    module ObjectAttribute
      class Text < Import::Zendesk::ObjectAttribute::Base

        def init_callback(_object_attribte)
          @data_option.merge!(
            type:      'text',
            maxlength: 255,
          )
        end

        private

        def data_type(_attribute)
          'input'
        end
      end
    end
  end
end
