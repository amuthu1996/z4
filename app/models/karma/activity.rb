# Copyright (C) 2012-2016 Zammad Foundation, http://zammad-foundation.org/

class Karma::Activity < ApplicationModel
  self.table_name = 'karma_activities'
  validates :name,      presence: true
end
