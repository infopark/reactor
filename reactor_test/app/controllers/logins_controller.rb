class LoginsController < ApplicationController
  def show
    render text: rsession.user_name
  end

  def create
    rsession.user_name = params[:user_name]
    head :ok
  end
end
