# -*- encoding : utf-8 -*-
class UpdateTestJob < Reactor::Migration
  def self.up
    update_job :name => 'test_job' do
      set :title, 'test_job other title'
      set :is_active, '1'
      set :comment, 'my comment (changed)'
      set :exec_login, 'not_root'
      set :script, 'obj wherePath / get title'
      set :schedule, [
        {:years => ['2014'], :months => ['11'], :minutes => ['10']}
      ]
    end
  end

  def self.down
    update_job :name => 'test_job' do
      set :title, 'test_job'
      set :is_active, '0'
      set :comment, 'my comment'
      set :exec_login, 'not_root'
      set :script, 'obj wherePath / get description'
      set :schedule, [
        {:years => ['2013'], :months => ['12'], :minutes => ['11']}
      ]
    end
  end
end
