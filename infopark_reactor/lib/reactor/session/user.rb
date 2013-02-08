# -*- encoding : utf-8 -*-
require 'reactor/cm/user'

module Reactor
  class Session
    class User
      def initialize(user_name)
        # Rails.logger.debug "Reading user #{user_name} from CM"
        user      = Reactor::Cm::User.new(user_name)
        @user_name= user_name
        @groups   = user.groups
        @language = user.language
        @superuser= user.is_root?
      end

      attr_reader :user_name, :groups, :language

      def superuser?
        @superuser == true
      end
    end
  end
end
