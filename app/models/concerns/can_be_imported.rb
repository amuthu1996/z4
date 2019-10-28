module CanBeImported
  extend ActiveSupport::Concern

  # methods defined here are going to extend the class, not the instance of it
  class_methods do
    def importable?
      true
    end
  end
end
