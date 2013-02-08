# -*- encoding : utf-8 -*-
Rails.application.routes.draw do
  post    'reactor/object'      => 'reactor#create_object',   :as => :create_object
  post    'reactor/release/:id' => 'reactor#release_object',  :as => :release_object
  delete  'reactor/object/:id'  => 'reactor#delete_object',   :as => :delete_object
  put     'reactor/object/:id'  => 'reactor#update_object',   :as => :update_object
end
