require 'active_support/notifications'

module ApiCachedAttributes
  module Notifications
    def instrument(*args, &block)
      args[0] = args[0] + '.api_cached_attributes' unless args[0].include?('.')
      ActiveSupport::Notifications.instrument(*args, &block)
    end
  end
end
