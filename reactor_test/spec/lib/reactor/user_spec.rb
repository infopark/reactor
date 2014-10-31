# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Reactor::Cm::User do

  subject { Reactor::Cm::User.new('root') }

  describe 'is_root?' do

    it 'returns true when the user is root' do
      subject.is_root?.should be_true
    end

    it 'returns false when the user is not root' do
      user = Reactor::Cm::User.new('not_root')

      user.is_root?.should be_false
    end

  end

  describe 'language' do

    it 'returns the language code the user has set' do
      subject.language.should eq('de')
    end

  end

  describe 'groups' do

    it 'returns a collection of the groups the user is a member of' do
      groups = subject.groups

      groups.should have(1).item
      groups.should include('admins')
    end

  end

  describe 'name' do

    it 'returns the name of the user' do
      subject.name.should eq('root')
    end

  end

  context 'user with global permissions' do
    before do
      @user = Reactor::Cm::User::Internal.create('global_permissions', 'not_root_group')
      @user.grant_global_permissions!(['permissionGlobalUserEdit', 'permissionGlobalMirrorHandling'])
      @user.save!
    end

    after do
      @user.delete!
    end

    subject { described_class.new('global_permissions') }

    it "has global permissions" do
      @user.global_permissions.should eq(['permissionGlobalUserEdit', 'permissionGlobalMirrorHandling'])
      subject.global_permissions.should eq(['permissionGlobalUserEdit', 'permissionGlobalMirrorHandling'])
    end
  end

  context 'user without global permissions' do
    describe 'global_permissions' do
      it 'returns global permissions' do
        subject.global_permissions.should eq([])
      end
    end
  end
end
