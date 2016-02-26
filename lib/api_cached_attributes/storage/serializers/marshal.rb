require_relative '../serializer'

module ApiCachedAttributes
  module Serializers
    class MarshalSerializer < Serializer
      def load(object)
        Marshal.load(object)
      end

      def dump(object)
        Marshal.dump(object)
      end
    end
  end
end
