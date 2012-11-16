require 'reactor/session'

module Reactor::Session::Observers
  class PermissionCacheInvalidator
    def update(user_name)
      #puts '%%% invalidating permission cache'
      Reactor::Cache::Permission.instance.invalidate(user_name)
    end
  end

  class UserCacheInvalidator
    def update(user_name)
      #puts '%%% invalidating user cache'
      Reactor::Cache::User.instance.invalidate(user_name)
    end
  end

  class CmsAccessDataPropagator
    def update(user_name)
      #puts '%%% propagating user'
      Reactor::Configuration.xml_access[:username] = user_name
    end
  end

  self.constants.each do |possible_observer_name|
    possible_observer = self.const_get(possible_observer_name)
    if possible_observer.method_defined?(:update)
      Reactor::Session.instance.add_observer(possible_observer.new)
    end
  end
end
  