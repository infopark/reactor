# -*- encoding : utf-8 -*-
module Reactor
  module Sudo
    def self.su(other_user_name, &block)
      rsession           = Reactor::Session.instance
      current_user_name  = rsession.user_name
      rsession.user_name = other_user_name
      yield
    ensure
      rsession.user_name = current_user_name || 'root'
    end
  end
end
