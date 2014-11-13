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

# require exceptions
require 'reactor/already_released'
require 'reactor/no_working_version'
require 'reactor/not_permitted'

# require components
require 'reactor/attributes'
require 'reactor/persistence'
require 'reactor/validations'
require 'reactor/permission'
require 'reactor/legacy'
require 'reactor/rc_independent'
require 'reactor/sudo'
require 'reactor/workflow'
require 'reactor/streaming_upload'

# require rails integration
require 'reactor/session'
require 'reactor/session/user'

# require engine
require File.expand_path('../engine', __FILE__) if defined?(Rails)
