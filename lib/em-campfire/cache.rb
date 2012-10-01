module EventMachine
  class Campfire
    class Cache
      def get(key)
        key = cache_key_for(key)
        yield store[key] if block_given?
        store[key]
      end

      def set(key, val)
        store[cache_key_for(key)] = val
      end

      private

      def cache_key_for(object)
        "em-campfire-#{object}"
      end

      def store
        @store ||= {}
      end
    end
  end
end