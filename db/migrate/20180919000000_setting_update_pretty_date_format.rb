class SettingUpdatePrettyDateFormat < ActiveRecord::Migration[5.1]
  def up

    # return if it's a new setup
    return if !Setting.find_by(name: 'system_init_done')

    setting = Setting.find_by(name: 'pretty_date_format')
    return if !setting

    setting.options[:form][0][:options][:timestamp] = 'timestamp - e. g. "2018-08-30 14:30"'
    setting.save!
  end

end
