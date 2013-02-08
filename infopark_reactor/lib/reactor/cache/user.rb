# -*- encoding : utf-8 -*-
require 'singleton'

module Reactor
  module Cache
    class User
      include Singleton

      def get(user_name)
        @cache ||= {}
        # Rails.logger.debug "User:Cache hit: #{hit?(user_name.to_s)} [#{@cache[user_name.to_s].inspect}]"

        key = user_name.to_s
        if hit?(key)
          @cache[key]
        else
          @cache[key] = Reactor::Session::User.new(key)
        end
      end

      def set(user_name, user)
        @cache ||= {}
        @cache[user_name.to_s] = user
      end

      def invalidate(user_name)
        @cache ||= {}
        @cache[user_name.to_s] = nil
      end

      private
      def hit?(user_name)
        key = user_name.to_s
        @cache.key?(key) && !@cache[key].nil?
      end
    end
  end
end
