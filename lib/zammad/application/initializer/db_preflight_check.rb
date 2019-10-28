require 'zammad/application/initializer/db_preflight_check/base'
require 'zammad/application/initializer/db_preflight_check/mysql2'
require 'zammad/application/initializer/db_preflight_check/postgresql'
require 'zammad/application/initializer/db_preflight_check/nulldb'

module Zammad
  class Application
    class Initializer
      module DBPreflightCheck
        def self.perform
          #adapter.perform
          true
        end

        def self.adapter
          @adapter ||= const_get(ActiveRecord::Base.connection_config[:adapter].capitalize)
          p "-----------------------------"
          p @adapter
        end
      end
    end
  end
end
