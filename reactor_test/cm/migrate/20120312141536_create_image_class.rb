# -*- encoding : utf-8 -*-
class CreateImageClass < Reactor::Migration
  def self.up
    unless Reactor::Cm::ObjClass.exists?('Image')
      create_class :name => 'Image', :type => 'image'
    end
    true
  end

  def self.down
    delete_class :name => 'Image'
  end
end
