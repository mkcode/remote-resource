require 'active_support/concern'
require 'active_support/rescuable'

module ApiCachedAttributes
  # Methods that help with loading and naming the Base class.
  module Rescue
    extend ActiveSupport::Concern
    include ActiveSupport::Rescuable

    # Public: Use the with_error_handling method to use the error handling
    # behavior defined in the rescue_from calls on the class. Take a block,
    # whose body will error rescued.
    #
    # Note that it is typically 'wrong' in Ruby to rescue Exception. In this
    # case it is OK because we re raise the error if it is not handled. Inspired
    # by ActiveController.
    #
    # Returns the last executed statement value.
    def with_error_handling(context = {})
      yield
    rescue Exception => exception
      rescue_with_handler(exception, context) || raise(exception)
    end

    private
    # Internal: Override the default ActiveSupport::Rescuable behavior to allow
    # for additional context argument to be supplied as well. These error
    # handlers are reused in different situations, and the context argument
    # allows one to change the behavior depending on which situation.
    def rescue_with_handler(exception, context = {})
      if handler = handler_for_rescue(exception)
        case handler.arity
        when 2 then handler.call(exception, context)
        when 1 then handler.call(exception)
        when 0 then handler.call
        end
        true # don't rely on the return value of the handler
      end
    end
  end
end
