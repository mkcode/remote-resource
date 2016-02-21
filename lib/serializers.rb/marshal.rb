module ApiCachedAttributes
  module Serializers
    class Marshal < ApiCachedAttributes::Serializer
      def load(object)
        Marshal.load(object)
      end

      def dump(object)
        Marshal.dump(object)
      end
    end
  end
end
