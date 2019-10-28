class SmsSupport < ActiveRecord::Migration[5.1]
  def up

    # return if it's a new setup
    return if !Setting.find_by(name: 'system_init_done')

    Permission.create_if_not_exists(
      name:        'admin.channel_sms',
      note:        'Manage %s',
      preferences: {
        translations: ['Channel - SMS']
      },
    )
  end
end
