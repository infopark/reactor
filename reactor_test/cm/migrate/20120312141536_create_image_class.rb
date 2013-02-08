# -*- encoding : utf-8 -*-
class CreateImageClass < Reactor::Migration
  def self.up
    create_class :name => 'Image', :type => 'image'
  end

  def self.down
    delete_class :name => 'Image'
  end
end
