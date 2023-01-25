# -*- encoding : utf-8 -*-
ReactorTest::Application.routes.draw do
  controller 'test' do
    get 'test' => :test, :as => :update_ll
  end

  resource :login, only: [:show, :create]

  get '/whatever' => "trivial#nothing"
end
