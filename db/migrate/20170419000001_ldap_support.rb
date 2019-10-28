class LdapSupport < ActiveRecord::Migration[4.2]
  def up

    # return if it's a new setup
    return if !Setting.find_by(name: 'system_init_done')

    if !ActiveRecord::Base.connection.table_exists? 'import_jobs'
      create_table :import_jobs do |t|
        t.string :name, limit: 250, null: false

        t.boolean :dry_run, default: false

        t.text :payload, limit: 80_000
        t.text :result, limit: 80_000

        t.datetime :started_at
        t.datetime :finished_at

        t.timestamps null: false
      end
    end

    Setting.create_or_update(
      title:       'Authentication via %s',
      name:        'auth_ldap',
      area:        'Security::Authentication',
      description: 'Enables user authentication via %s.',
      preferences: {
        title_i18n:       ['LDAP'],
        description_i18n: ['LDAP'],
        permission:       ['admin.security'],
      },
      state:       {
        adapter:          'Auth::Ldap',
        login_attributes: %w[login email],
      },
      frontend:    false
    )

    Setting.create_if_not_exists(
      title:       'LDAP integration',
      name:        'ldap_integration',
      area:        'Integration::Switch',
      description: 'Defines if LDAP is enabled or not.',
      options:     {
        form: [
          {
            display: '',
            null:    true,
            name:    'ldap_integration',
            tag:     'boolean',
            options: {
              true  => 'yes',
              false => 'no',
            },
          },
        ],
      },
      state:       false,
      preferences: {
        prio:           1,
        authentication: true,
        permission:     ['admin.integration'],
      },
      frontend:    true
    )
    Setting.create_if_not_exists(
      title:       'LDAP config',
      name:        'ldap_config',
      area:        'Integration::LDAP',
      description: 'Defines the LDAP config.',
      options:     {},
      state:       {},
      preferences: {
        prio:       2,
        permission: ['admin.integration'],
      },
      frontend:    false,
    )

    Scheduler.create_or_update(
      name:          'Import Jobs',
      method:        'ImportJob.start_registered',
      period:        1.hour,
      prio:          1,
      active:        true,
      updated_by_id: 1,
      created_by_id: 1
    )

    Setting.create_if_not_exists(
      title:       'Import Backends',
      name:        'import_backends',
      area:        'Import',
      description: 'A list of active import backends that get scheduled automatically.',
      options:     {},
      state:       ['Import::Ldap'],
      preferences: {
        permission: ['admin'],
      },
      frontend:    false
    )

  end

end
