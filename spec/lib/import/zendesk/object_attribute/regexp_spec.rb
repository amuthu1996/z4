require 'rails_helper'
require 'lib/import/zendesk/object_attribute/base_examples'

# required due to some of rails autoloading issues
require 'import/zendesk/object_attribute/regexp'

RSpec.describe Import::Zendesk::ObjectAttribute::Regexp do
  it_behaves_like Import::Zendesk::ObjectAttribute::Base

  it 'imports input object attribute from regexp object field' do

    regex     = '.+?'
    attribute = double(
      title:                 'Example attribute',
      description:           'Example attribute description',
      removable:             false,
      active:                true,
      position:              12,
      visible_in_portal:     true,
      required_in_portal:    true,
      required:              true,
      type:                  'regexp',
      regexp_for_validation: regex
    )

    expected_structure = {
      object:        'Ticket',
      name:          'example_field',
      display:       'Example attribute',
      data_type:     'input',
      data_option:   {
        null:      false,
        note:      'Example attribute description',
        type:      'text',
        maxlength: 255,
        regex:     regex,
      },
      editable:      true,
      active:        true,
      screens:       {
        edit: {
          Customer: {
            shown: true,
            null:  false
          },
          view:     {
            '-all-' => {
              shown: true
            }
          }
        }
      },
      position:      12,
      created_by_id: 1,
      updated_by_id: 1
    }

    expect(ObjectManager::Attribute).to receive(:add).with(expected_structure)
    expect(ObjectManager::Attribute).to receive(:migration_execute)

    described_class.new('Ticket', 'example_field', attribute)
  end
end
