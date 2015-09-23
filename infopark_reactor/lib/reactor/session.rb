# -*- encoding : utf-8 -*-
require 'observer'

require 'reactor/cm/bridge'
require 'reactor/cache/user'
require 'reactor/session/observers'

class Reactor::Session
  attr_reader :user_name, :session_id
  include Observable

  def self.instance
    self.for(Reactor::Configuration.xml_access[:username])
  end

  def self.for(user_name)
    self.new.tap do |instance|
      instance.instance_variable_set(:@user_name, user_name)
      instance.send(:proper_notify_observers, user_name, false)
    end
  end

  def marshal_dump
    [@user_name, @session_id]
  end

  def marshal_load(array)
    @user_name, @session_id = array
    self.add_observers
    self.proper_notify_observers(@user_name, false)
  end

  def initialize
    self.add_observers
  end


  def login(session_id)
    if !logged_in?(session_id)
      self.user_name = authenticate(session_id)
    end
  end

  def destroy
    self.session_id = self.user_name = nil
  end

  def logged_in?(session_id)
    self.session_id.present? && self.user? && self.session_id == session_id
  end

  def user?
    self.user_name.present?
  end

  def user
    Reactor::Cache::User.instance.get(self.user_name)
  end

  def user_name=(new_user_name)
    @user_name = new_user_name
    self.proper_notify_observers(@user_name, true)
    @user_name
  end

  protected
  attr_writer :session_id

  def authenticate(session_id)
    self.session_id = session_id
    Reactor::Cm::Bridge.login_for(session_id)
  end

  def add_observers
    Observers.constants.each do |possible_observer_name|
      possible_observer = Observers.const_get(possible_observer_name)
      if possible_observer.method_defined?(:update)
        self.add_observer(possible_observer.new)
      end
    end
  end

  def proper_notify_observers(*args)
    self.changed(true)
    self.notify_observers(*args)
  end
end
