require 'delayed_job'

class ResetSettingsPlugin < Delayed::Plugin

  callbacks do |lifecycle|
    lifecycle.before(:invoke_job) do |*_args|

      Rails.logger.debug { 'Resetting Settings before Job execution' }

      # reload all settings before starting a job
      # otherwise it might be that changed settings
      # from other processes (e.g. Rails server)
      # are reflected and obsolete, cached values
      # are wrongfully used
      Setting.reload
    end
  end
end

Delayed::Worker.plugins << ResetSettingsPlugin
