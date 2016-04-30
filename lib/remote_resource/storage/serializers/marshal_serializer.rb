require_relative '../serializer'

module RemoteResource
  module Storage
    module Serializers
      class MarshalSerializer < Serializer
        def load(object)
          return nil unless object
          Marshal.load(object)
        end

        def dump(object)
          Marshal.dump(object)
        end
      end
    end
  end
end
