# -*- encoding : utf-8 -*-
class TrivialController < ActionController::Base
  def nothing
    render :plain => 'but something'
  end
end
