require 'active_support/log_subscriber'

module ApiCachedAttributes
  class LogSubscriber < ActiveSupport::LogSubscriber
    def logger
      ApiCachedAttributes.logger
    end

    def find(event)
      log_action('Find', event)
    end

    def storage_lookup(event)
      log_action('Storage lookup', event) { |payload| payload[:attribute] }
    end

    def http_get(event)
      log_action('HTTP GET', event) { |payload| payload[:attribute] }
    end

    # the optional block acts as a filter for the log description. The block is
    # passed the payload and its return value is used as the log description.
    # The whole payload is used as the description if the block is omitted.
    def log_action action, event, &block
      payload = event.payload
      description = block ? block.call(payload) : payload

      if attribute = payload[:attribute]
        subject = attribute[:location]
        action = "#{subject} #{action} (#{event.duration.round(2)}ms)"
      end

      action = color(action, GREEN, true)
      debug("#{action} #{description}")
    end
  end
end

ApiCachedAttributes::LogSubscriber.attach_to :api_cached_attributes
