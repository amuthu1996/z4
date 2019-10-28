module Mixin
  module RailsLogger
    # add logger method for instance method access
    extend Forwardable
    extend SingleForwardable

    instance_delegate [:logger] => self
    single_delegate   [:logger] => :Rails

    # add logger method for class method access
    def self.included(base)
      base.extend(SingleForwardable)
      base.single_delegate [:logger] => :Rails
    end
  end
end
