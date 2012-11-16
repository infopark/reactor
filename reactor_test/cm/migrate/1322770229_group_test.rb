class GroupTest < Reactor::Migration

  def self.up
    create_group :name => 'created_group' do
      set :real_name, 'test real name'
      set :owner, 'not_root'
      set :users, ['not_root', 'root']
      set :global_permissions, ['permissionGlobalRoot', 'permissionGlobalExport']
    end

    update_group :name => 'created_group' do
      set :real_name, 'changed real name'
      set :owner, 'root'
      set :users, ['root']
      set :global_permissions, ['permissionGlobalMirrorHandling']
    end

    rename_group :from => 'created_group', :to => 'renamed_created_group'

    delete_group :name => 'renamed_created_group'
  end

  def self.down
  end

end
