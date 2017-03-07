# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Reactor::Cm::Group do

  before(:all) { 
    @group = described_class.create(
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
    expect(subject.class).to be_exists('created_group')
  end

  it 'sets the real name' do
    expect(@group.real_name).to eq('test real name')
  end

  it 'sets the owner' do
    expect(@group.owner).to eq('not_root')
  end

  it 'sets the users' do
    %w{root not_root}.each do |user|
      expect(@group.users).to include(user)
    end
  end

  it 'sets the global permissions' do
    %w{permissionGlobalUserEdit permissionGlobalMirrorHandling}.each do |name|
      expect(@group.global_permissions).to include(name)
    end
  end

  describe 'all' do
    
    it 'returns a list of all groups' do
      groups = subject.class.all.map(&:name)

      expect(groups.size).to be >= 3

      %w{admins not_root_group created_group}.each do |name|
        expect(groups).to include(name)
      end
    end

    it 'matches groups with the given term' do |name|
      groups = subject.class.all('not_root').map(&:name)

      expect(groups.size).to eq(1)

      %w{not_root_group}.each do |name|
        expect(groups).to include(name)
      end
    end

    it 'returns an empty collection when no group can be found' do
      groups = subject.class.all('non-existing-group')

      expect(groups.size).to eq(0)
    end
    
  end

  describe 'exists' do
    
    it 'returns false if the group does not exist' do
      expect(subject.class.exists?('not_existing_group')).to be_falsey
    end

    it 'returns true if the group exists' do
      expect(subject.class.exists?('created_group')).to be_truthy
    end

  end

  describe 'get' do
    
    it 'returns a group object with all attributes set' do
      group = subject.class.get('created_group')

      %w{name real_name owner users global_permissions}.each do |name|
        expect(group.send(name)).to eq(@group.send(name))
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

      expect(@group.save!).to be_truthy

      %w{real_name owner users global_permissions}.each do |name|
        expect(@group.send(name)).to eq(attributes[name.to_sym])
      end
    end
  end

  describe 'rename' do
    
    it 'renames the group to the given name' do
      group = @group.rename!('renamed_created_group')

      expect(group.name).to eq('renamed_created_group')

      %w{real_name owner users global_permissions}.each do |name|
        expect(group.send(name)).to eq(@group.send(name))
      end

      group.rename!('created_group')
    end

  end

end
