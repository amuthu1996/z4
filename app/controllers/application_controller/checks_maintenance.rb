module ApplicationController::ChecksMaintenance
  extend ActiveSupport::Concern

  private

  def in_maintenance_mode?(user)
    return false if Setting.get('maintenance_mode') != true
    return false if user.permissions?('admin.maintenance')

    Rails.logger.info "Maintenance mode enabled, denied login for user #{user.login}, it's no admin user."
    true
  end
end
