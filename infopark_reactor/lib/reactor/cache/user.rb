module Reactor
  module Cache
    class User
      BACKING_CACHE_EXPIRATION = 5

      def self.instance
        new
      end

      def initialize
        @@backing_storage ||= ActiveSupport::Cache::MemoryStore.new({ size: 1.megabyte })
      end

      def get(user_name)
        @cache ||= {}
        # Rails.logger.debug "User:Cache hit: #{hit?(user_name.to_s)} [#{@cache[user_name.to_s].inspect}]"

        key = user_name.to_s
        @@backing_storage.fetch(key, expires_in: BACKING_CACHE_EXPIRATION.minutes) do
          Reactor::Session::User.new(key)
        end
      end

      def set(user_name, user)
        @@backing_storage.write(user_name.to_s, user, expires_in: BACKING_CACHE_EXPIRATION.minutes)
      end

      def invalidate(user_name)
        @@backing_storage.delete(user_name.to_s)
      end
    end
  end
end
