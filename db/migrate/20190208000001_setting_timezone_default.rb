class SettingTimezoneDefault < ActiveRecord::Migration[5.1]
  def up
    # return if it's a new setup
    return if !Setting.find_by(name: 'system_init_done')

    Setting.create_if_not_exists(
      title:       'Timezone',
      name:        'timezone_default',
      area:        'System::Branding',
      description: 'Defines the system default timezone.',
      options:     {
        form: [
          {
            name: 'timezone_default',
          }
        ],
      },
      state:       '',
      preferences: {
        prio:       9,
        controller: 'SettingsAreaItemDefaultTimezone',
        permission: ['admin.system'],
      },
      frontend:    true
    )
  end
end
