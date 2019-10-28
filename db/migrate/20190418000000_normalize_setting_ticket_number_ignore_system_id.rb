class NormalizeSettingTicketNumberIgnoreSystemId < ActiveRecord::Migration[5.1]
  def up
    return if !Setting.find_by(name: 'system_init_done')
    return if !Setting.exists?(name: 'ticket_number_ignore_system_id')

    Setting.find_by(name:  'ticket_number_ignore_system_id')
           .update(state_initial: { value: false })

    return if Setting.get('ticket_number_ignore_system_id') != { 'ticket_number_ignore_system_id' => false }

    Setting.set('ticket_number_ignore_system_id', false)
  end
end
