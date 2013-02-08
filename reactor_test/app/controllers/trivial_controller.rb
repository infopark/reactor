# -*- encoding : utf-8 -*-
class TrivialController < ActionController::Base
  def nothing
    render :text => 'but something'
  end
end
