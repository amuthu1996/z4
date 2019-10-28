require 'rails_helper'
require 'lib/import/zendesk/object_attribute/base_examples'

RSpec.describe Import::Zendesk::ObjectAttribute::Checkbox do
  it_behaves_like Import::Zendesk::ObjectAttribute::Base

  it 'imports boolean object attribute from checkbox object field' do

    attribute = double(
      title:              'Example attribute',
      description:        'Example attribute description',
      removable:          false,
      active:             true,
      position:           12,
      visible_in_portal:  true,
      required_in_portal: true,
      required:           true,
      type:               'checkbox',
    )

    expected_structure = {
      object:        'Ticket',
      name:          'example_field',
      display:       'Example attribute',
      data_type:     'boolean',
      data_option:   {
        null:    false,
        note:    'Example attribute description',
        default: false,
        options: {
          true  => 'yes',
          false => 'no'
        }
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
