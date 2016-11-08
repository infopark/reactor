# -*- encoding : utf-8 -*-
require 'observer'

require 'reactor/cm/bridge'
require 'reactor/cache/user'
require 'reactor/session/observers'

class Reactor::Session
  include Observable

  class State < Struct.new(:user_name, :session_id)
    def serialize
      [self.user_name, self.session_id]
    end

    def self.deserialize(array)
      self.new(*array)
    end
  end

  def initialize(state=State.new)
    self.initialize_and_notify(state)
  end

  def user_name
    self.state.user_name
  end

  def session_id
    self.state.session_id
  end

  def self.instance
    self.for(Reactor::Configuration.xml_access[:username])
  end

  def self.for(user_name)
    self.new(State.new(user_name, nil))
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
    self.state.user_name = new_user_name
    self.proper_notify_observers(new_user_name, true)
    new_user_name
  end

  def marshal_dump
    self.state.serialize
  end

  def marshal_load(array)
    self.initialize_and_notify(State.deserialize(array))
  end

  protected
  attr_accessor :state
  def initialize_and_notify(state)
    self.state = state
    self.add_observers
    self.proper_notify_observers(self.user_name, false)
  end

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

  def session_id=(new_session_id)
    self.state.session_id = new_session_id
  end
end
