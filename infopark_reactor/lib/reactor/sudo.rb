module Reactor
  module Sudo
    def self.su(other_user_name, &block)
      current_user_name = Reactor::Session.instance.user_name
      Reactor::Session.instance.user_name = other_user_name
      yield
    ensure
      Reactor::Session.instance.user_name = current_user_name || 'root'
    end
  end
end