module Reactor
  class Session
    module Observers
      class PermissionCacheInvalidator
        def update(user_name, new_login = false)
          Reactor::Cache::Permission.instance.invalidate(user_name) if new_login
        end
      end

      class UserCacheInvalidator
        def update(user_name, new_login = false)
          Reactor::Cache::User.instance.invalidate(user_name) if new_login
        end
      end

      class CmsAccessDataPropagator
        def update(user_name, _new_login = false)
          Reactor::Configuration.xml_access[:username] = user_name
        end
      end
    end
  end
end
