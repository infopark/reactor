# -*- encoding : utf-8 -*-
# Runtime Rails version detection
module Reactor
  def self.rails3_0?
    ::Rails::VERSION::MAJOR == 3 && ::Rails::VERSION::MINOR == 0
  end

  def self.rails3_1?
    ::Rails::VERSION::MAJOR == 3 && ::Rails::VERSION::MINOR == 1
  end

  def self.rails3_2?
    ::Rails::VERSION::MAJOR == 3 && ::Rails::VERSION::MINOR == 2
  end

  def self.rails4_0?
    ::Rails::VERSION::MAJOR == 4 && ::Rails::VERSION::MINOR == 0
  end

  def self.rails4_1?
    ::Rails::VERSION::MAJOR == 4 && ::Rails::VERSION::MINOR == 1
  end

  def self.rails4_0_ge6?
    ::Rails::VERSION::MAJOR == 4 && ::Rails::VERSION::MINOR == 0 && ::Rails::VERSION::TINY >= 6
  end
end
# require config
require 'reactor/configuration'


# require components
require 'reactor/cm/bridge'
require 'reactor/cm/language'
require 'reactor/cm/object_base'
require 'reactor/cm/user'
require 'reactor/cm/attribute'
require 'reactor/cm/obj'
require 'reactor/cm/obj_class'
require 'reactor/cm/attribute_group'
require 'reactor/cm/link'
require 'reactor/cm/group'
require 'reactor/cm/editorial_group'
require 'reactor/cm/live_group'
require 'reactor/cm/workflow'
require 'reactor/cm/log_entry'
require 'reactor/cm/channel'

# require main class
require 'reactor/migration'

# require misc
require 'reactor/cm/xml_request_error'
require 'reactor/cm/missing_credentials'

# require public tools
require 'reactor/tools/uploader'

# require exceptions
require 'reactor/already_released'
require 'reactor/no_working_version'
require 'reactor/not_permitted'

# require components
require 'reactor/main'
require 'reactor/rc_independent'
require 'reactor/sudo'

# require rails integration
require 'reactor/session'
require 'reactor/session/user'

# require engine
require File.expand_path('../reactor/engine', __FILE__) if defined?(Rails)
