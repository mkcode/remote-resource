require 'logger'

module ApiCachedAttributes
  module Configuration
    # Our humble logger
    module Logger
      def self.extended(klass)
        klass.instance_variable_set(:@logger, nil)
      end

      def logger=(logger)
        @logger = logger
      end

      def logger
        @logger || default_logger
      end

      def default_logger
        ::Logger.new(STDOUT)
      end
    end
  end
end
