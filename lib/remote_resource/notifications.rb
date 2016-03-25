require 'active_support/notifications'

module RemoteResource
  module Notifications
    def instrument(*args, &block)
      args[0] = args[0] + '.remote_resource' unless args[0].include?('.')
      ActiveSupport::Notifications.instrument(*args, &block)
    end

    def instrument_attribute(*args, &block)
      fail ArgumentError unless args[1].is_a? AttributeSpecification
      args.push({}) unless args.last.is_a? Hash
      args.last.merge!(attribute: args.delete_at(1).to_hash)
      instrument(*args, &block)
    end
  end
end
