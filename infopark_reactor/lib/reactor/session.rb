require "observer"

require "reactor/cm/bridge"
require "reactor/cache/user"
require "reactor/session/observers"

class Reactor::Session
  include Observable

  class State < Struct.new(:user_name, :session_id)
    def serialize
      [user_name, session_id]
    end

    def self.deserialize(array)
      new(*array)
    end
  end

  def initialize(state = State.new)
    initialize_and_notify(state)
  end

  def user_name
    state.user_name
  end

  def session_id
    state.session_id
  end

  def self.instance
    self.for(Reactor::Configuration.xml_access[:username])
  end

  def self.for(user_name)
    new(State.new(user_name, nil))
  end

  def login(session_id)
    self.user_name = authenticate(session_id) unless logged_in?(session_id)
  end

  def destroy
    self.session_id = self.user_name = nil
  end

  def logged_in?(session_id)
    self.session_id.present? && user? && self.session_id == session_id
  end

  def user?
    user_name.present?
  end

  def user
    Reactor::Cache::User.instance.get(user_name)
  end

  def user_name=(new_user_name)
    state.user_name = new_user_name
    proper_notify_observers(new_user_name, true)
  end

  def marshal_dump
    state.serialize
  end

  def marshal_load(array)
    initialize_and_notify(State.deserialize(array))
  end

  protected

  attr_accessor :state

  def initialize_and_notify(state)
    self.state = state
    add_observers
    proper_notify_observers(user_name, false)
  end

  def authenticate(session_id)
    self.session_id = session_id
    Reactor::Cm::Bridge.login_for(session_id)
  end

  def add_observers
    Observers.constants.each do |possible_observer_name|
      possible_observer = Observers.const_get(possible_observer_name)
      add_observer(possible_observer.new) if possible_observer.method_defined?(:update)
    end
  end

  def proper_notify_observers(*args)
    changed(true)
    notify_observers(*args)
  end

  def session_id=(new_session_id)
    state.session_id = new_session_id
  end
end
