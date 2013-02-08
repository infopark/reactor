# -*- encoding : utf-8 -*-
class CreateSimpleChannel < Reactor::Migration
  def self.up
    create_channel :name => 'my.simple.channel' do
      set :title, 'My Channel'
    end
  end

  def self.down
    delete_channel :name => 'my.simple.channel'
  end
end
