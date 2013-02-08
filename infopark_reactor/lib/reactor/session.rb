# -*- encoding : utf-8 -*-
require 'singleton'
require 'observer'

require 'reactor/cm/bridge'
require 'reactor/cache/user'

class Reactor::Session
  attr_reader :user_name, :session_id
  include Singleton
  include Observable

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
    changed(true) # I will find and burn your house to the ground if you remove this line
    notify_observers(@user_name)
  end

  protected
  attr_writer :session_id

  def authenticate(session_id)
    self.session_id = session_id
    Reactor::Cm::Bridge.login_for(session_id)
  end

end
