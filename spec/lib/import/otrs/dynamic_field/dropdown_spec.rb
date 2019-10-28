require 'rails_helper'
require 'lib/import/otrs/dynamic_field_examples'

RSpec.describe Import::OTRS::DynamicField::Dropdown do
  it_behaves_like 'Import::OTRS::DynamicField'

  it 'imports an OTRS Dropdown DynamicField' do

    zammad_structure = {
      object:        'Ticket',
      name:          'dropdown_example',
      display:       'Dropdown Example',
      screens:       {
        view: {
          '-all-' => {
            shown: true
          }
        }
      },
      active:        true,
      editable:      true,
      position:      '30',
      created_by_id: 1,
      updated_by_id: 1,
      data_type:     'select',
      data_option:   {
        default:    '',
        multiple:   false,
        options:    {
          'Hamburg' => 'Hamburg',
          'München' => 'München',
          'Köln'    => 'Köln',
          'Berlin'  => 'Berlin'
        },
        nulloption: true,
        null:       true,
        translate:  false
      }
    }

    dynamic_field_from_json('dropdown/default', zammad_structure)
  end
end
