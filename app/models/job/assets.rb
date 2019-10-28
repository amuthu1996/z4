# Copyright (C) 2012-2016 Zammad Foundation, http://zammad-foundation.org/

class Job
  module Assets
    extend ActiveSupport::Concern

=begin

get all assets / related models for this job

  job = Job.find(123)
  result = job.assets(assets_if_exists)

returns

  result = {
    :jobs => {
      123  => job_model_123,
      1234 => job_model_1234,
    }
  }

=end

    def assets(data)

      app_model = Job.to_app_model

      if !data[ app_model ]
        data[ app_model ] = {}
      end
      if !data[ User.to_app_model ]
        data[ User.to_app_model ] = {}
      end
      if !data[ app_model ][ id ]
        data[ app_model ][ id ] = attributes_with_association_ids
        data = assets_of_selector('condition', data)
        data = assets_of_selector('perform', data)
      end
      %w[created_by_id updated_by_id].each do |local_user_id|
        next if !self[ local_user_id ]
        next if data[ User.to_app_model ][ self[ local_user_id ] ]

        user = User.lookup(id: self[ local_user_id ])
        next if !user

        data = user.assets(data)
      end
      data
    end
  end
end
