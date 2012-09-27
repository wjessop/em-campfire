module EventMachine
  class Campfire
    class Cache < Hash
      def get(key)
        key = cache_key_for(key)
        yield self[key] if block_given?
        self[key]
      end

      def set(key, val)
        self[cache_key_for(key)] = val
      end

      private

      def cache_key_for(object)
        "em-campfire-#{object}"
      end
    end
  end
end