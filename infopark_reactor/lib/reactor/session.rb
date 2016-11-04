# -*- encoding : utf-8 -*-
require 'observer'

require 'reactor/cm/bridge'
require 'reactor/cache/user'
require 'reactor/session/observers'

class Reactor::Session
  include Observable

  USER_NAME_STATE_KEY  = 0
  SESSION_ID_STATE_KEY = 1

  def self.instance
    self.for(Reactor::Configuration.xml_access[:username])
  end

  def self.for(user_name, session_id=nil)
    self.allocate.tap do |instance|
      instance.load_state([user_name, session_id])
    end
  end

  def marshal_dump
    @state.dup
  end

  def marshal_load(state_array)
    # NOTE: this dup is very important, because the array
    # passed to load state is ment to modified in-place
    self.load_state(state_array.dup)
  end

  def load_state(state_array)
    @state = state_array
    self.add_observers
    self.proper_notify_observers(self.user_name, false)
  end

  def initialize
    @state = []
    self.add_observers
  end

  def login(session_id)
    if !logged_in?(session_id)
      self.set_user_name(self.authenticate(session_id))
    end
  end

  def destroy
    # this will notify the observers
    self.user_name = nil
    # this will just clean the state
    self.set_user_name(nil)
    self.set_session_id(nil)
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
    self.set_user_name(new_user_name)
    self.proper_notify_observers(new_user_name, true)
    new_user_name
  end


  def user_name
    @state[USER_NAME_STATE_KEY]
  end

  def session_id
    @state[SESSION_ID_STATE_KEY]
  end

  protected
  def set_user_name(user_name)
    @state[USER_NAME_STATE_KEY] = user_name
  end

  def set_session_id(session_id)
    @state[SESSION_ID_STATE_KEY] = session_id
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
end
