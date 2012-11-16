class CreateGenericClass < Reactor::Migration
  def self.up
    create_class :name => 'Generic', :type => 'generic'
  end

  def self.down
    delete_class :name => 'Generic'
  end
end