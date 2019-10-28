# Copyright (C) 2012-2016 Zammad Foundation, http://zammad-foundation.org/

module Import
  class Zendesk < Import::Base
    include Import::Mixin::Sequence

    def start
      process
    end

    def sequence_name
      'Import::Zendesk::Full'
    end
  end
end
