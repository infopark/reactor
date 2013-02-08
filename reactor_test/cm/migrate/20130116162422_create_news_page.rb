# -*- encoding : utf-8 -*-
class CreateNewsPage < Reactor::Migration
  def self.up
    create_class :name => 'NewsPage', :type => 'publication' do
      set :canCreateNewsItems, '1'
    end
  end

  def self.down
    delete_class :name => 'NewsPage'
  end
end
