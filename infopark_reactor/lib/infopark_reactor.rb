# -*- encoding : utf-8 -*-
# Runtime Rails version detection
module Reactor
  def self.rails3_x?
    ::Rails::VERSION::MAJOR == 3
  end

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

  def self.rails4_2?
    ::Rails::VERSION::MAJOR == 4 && ::Rails::VERSION::MINOR == 2
  end

  def self.rails4_x?
    ::Rails::VERSION::MAJOR == 4 && [0,1,2].include?(::Rails::VERSION::MINOR)
  end

  def self.rails4_0_ge6?
    ::Rails::VERSION::MAJOR == 4 && ::Rails::VERSION::MINOR == 0 && ::Rails::VERSION::TINY >= 6
  end

  def self.rails5_x?
    ::Rails::VERSION::MAJOR == 5 && [0,1,2].include?(::Rails::VERSION::MINOR)
  end
end

require 'standard_loader'
if Reactor.rails5_x?
  require 'rails5_loader'
else
  require 'legacy_rails_loader'
end
# require engine
require File.expand_path('../reactor/engine', __FILE__) if defined?(Rails)
