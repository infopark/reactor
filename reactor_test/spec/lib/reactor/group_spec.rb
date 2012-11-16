require 'spec_helper'

describe Reactor::Cm::Group do

  before(:all) { 
    @group = subject.class.create(
      :name => 'created-group', 
      :real_name => 'test real name',
      :owner => 'not_root', 
      :users => ['root', 'not_root'], 
      :global_permissions => ['permissionGlobalUserEdit', 'permissionGlobalMirrorHandling']
    )

    @group.save! 
  }
  
  after(:all) { 
    @group.delete!
  }


  it 'creates a group' do
    subject.class.should be_exists('created_group')
  end

  it 'sets the real name' do
    @group.real_name.should eq('test real name')
  end

  it 'sets the owner' do
    @group.owner.should eq('not_root')
  end

  it 'sets the users' do
    %w{root not_root}.each do |user|
      @group.users.should include(user)
    end
  end

  it 'sets the global permissions' do
    %w{permissionGlobalUserEdit permissionGlobalMirrorHandling}.each do |name|
      @group.global_permissions.should include(name)
    end
  end

  describe 'all' do
    
    it 'returns a list of all groups' do
      groups = subject.class.all

      groups.should have_at_least(3).items

      %w{admins not_root_group created_group}.each do |name|
        groups.should include(name)
      end
    end

    it 'matches groups with the given term' do |name|
      groups = subject.class.all('not_root')

      groups.should have(1).items

      %w{not_root_group}.each do |name|
        groups.should include(name)
      end
    end

    it 'returns an empty collection when no group can be found' do
      groups = subject.class.all('non-existing-group')

      groups.should have(0).items
    end
    
  end

  describe 'exists' do
    
    it 'returns false if the group does not exist' do
      subject.class.exists?('not_existing_group').should be_false
    end

    it 'returns true if the group exists' do
      subject.class.exists?('created_group').should be_true
    end

  end

  describe 'get' do
    
    it 'returns a group object with all attributes set' do
      group = subject.class.get('created_group')

      %w{name real_name owner users global_permissions}.each do |name|
        group.send(name).should eq(@group.send(name))
      end
    end

  end

  describe 'save' do
    
    it 'returns true if the group is saved successfully' do
      attributes = {
        :real_name => 'changed real name',
        :owner => 'root',
        :users => ['not_root'],
        :global_permissions => ['permissionGlobalRoot', 'permissionGlobalExport'],
      }

      attributes.each do |key, value|
        @group.send("#{key}=", value)
      end

      @group.save!.should be_true

      %w{real_name owner users global_permissions}.each do |name|
        @group.send(name).should eq(attributes[name.to_sym])
      end
    end
  end

  describe 'rename' do
    
    it 'renames the group to the given name' do
      group = @group.rename!('renamed_created_group')

      group.name.should eq('renamed_created_group')

      %w{real_name owner users global_permissions}.each do |name|
        group.send(name).should eq(@group.send(name))
      end

      group.rename!('created_group')
    end

  end

end
