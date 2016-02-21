module ApiAttrs
  module Serializers
    class Marshal < ApiAttrs::Serializer
      def load(object)
        Marshal.load(object)
      end

      def dump(object)
        Marshal.dump(object)
      end
    end
  end
end
