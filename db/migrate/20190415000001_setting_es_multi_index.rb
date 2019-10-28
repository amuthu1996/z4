class SettingEsMultiIndex < ActiveRecord::Migration[5.1]
  def up

    # return if it's a new setup
    return if !Setting.find_by(name: 'system_init_done')

    Setting.create_if_not_exists(
      title:       'Elasticsearch Multi Index',
      name:        'es_multi_index',
      area:        'SearchIndex::Elasticsearch',
      description: 'Define if Elasticsearch is using multiple indexes.',
      state:       false,
      preferences: { online_service_disable: true },
      frontend:    false
    )

  end
end
