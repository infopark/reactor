# -*- encoding : utf-8 -*-
class TitlePreset < Reactor::Migration
  def self.up
    update_class name: 'publication' do
      preset :title, 'test'
    end
  end

  def self.down
    false
  end
end
