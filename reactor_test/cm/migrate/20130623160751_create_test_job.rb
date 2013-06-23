# -*- encoding : utf-8 -*-
class CreateTestJob < Reactor::Migration
  def self.up
    create_job :name => 'test_job' do
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

  def self.down
    delete_job :name => 'test_job'
  end
end
