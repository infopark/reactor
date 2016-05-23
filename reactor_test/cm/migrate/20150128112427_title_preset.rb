# -*- encoding : utf-8 -*-
class TitlePreset < Reactor::Migration
  def self.up
    if !Reactor::Cm::ObjClass.exists?('publication')
      create_class name: 'publication', type: 'publication' do
      end
    end

    update_class name: 'publication' do
      preset :title, 'test'
    end
  end

  def self.down
    false
  end
end
