# -*- encoding : utf-8 -*-
class DeleteTestJob < Reactor::Migration
  def self.up
    delete_job :name => 'test_job'
  end

  def self.down
    false
  end
end
