require 'singleton'

module Reactor
  module Cache
    class Permission
      include Singleton

      def lookup(user, key, &block)
        set(user, key, yield) unless set?(user, key)
        get(user, key)
      end

      def initialize
        @cache = {}
      end

      def invalidate(user)
        @cache[user] = {}
      end

      protected
      def set?(user, key)
        @cache.key?(user) && @cache[user].include?(key)
      end

      def set(user, key, value)
        @cache[user] ||= {}
        @cache[user][key] = value
      end

      def get(user, key)
        @cache[user][key]
      end
    end
  end
end