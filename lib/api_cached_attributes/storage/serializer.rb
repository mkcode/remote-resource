module ApiCachedAttributes
  module Storage
    class UnImplemntedError < StandardError; end;

    class Serializer
      def load(object)
        fail UnImplemntedError "Must implement serializer#load"
      end

      def dump(object)
        fail UnImplemntedError "Must implement serializer#dump"
      end
    end
  end
end
