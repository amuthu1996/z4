# This migration removes all pre-existing user sessions
# so that they can be replaced with sessions that use "secure cookies".
# It is skipped on non-HTTPS deployments
# because those are incompatible with secure cookies anyway.
class ForgetInsecureSessions < ActiveRecord::Migration[5.2]
  def up
    return if !Setting.find_by(name: 'system_init_done')
    return if Setting.get('http_type') != 'https'

    ActiveRecord::SessionStore::Session.destroy_all
  end
end
