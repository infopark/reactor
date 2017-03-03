# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Reactor::Cm::User do

  subject { Reactor::Cm::User.new('root') }

  describe 'is_root?' do

    it 'returns true when the user is root' do
      expect(subject.is_root?).to be_truthy
    end

    it 'returns false when the user is not root' do
      user = Reactor::Cm::User.new('not_root')

      expect(user.is_root?).to be_falsey
    end

  end

  describe 'language' do

    it 'returns the language code the user has set' do
      expect(subject.language).to eq('de')
    end

  end

  describe 'groups' do

    it 'returns a collection of the groups the user is a member of' do
      groups = subject.groups

      expect(groups.size).to eq(1)
      expect(groups).to include('admins')
    end

  end

  describe 'email' do
    let(:user_with_email) { described_class.new('spresley') }
    let(:user_without_email) { described_class.new('not_root') }

    it 'returns the email of the user' do
      expect(user_with_email.email).to eql "spresley@infopark"
    end

    it 'returns nil for when email missing' do
      expect(user_without_email.email).to eql(nil)
    end

  end

  describe 'name' do

    it 'returns the name of the user' do
      expect(subject.name).to eq('root')
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
      expect(@user.global_permissions).to eq(['permissionGlobalUserEdit', 'permissionGlobalMirrorHandling'])
      expect(subject.global_permissions).to eq(['permissionGlobalUserEdit', 'permissionGlobalMirrorHandling'])
    end
  end

  context 'user without global permissions' do
    describe 'global_permissions' do
      it 'returns global permissions' do
        expect(subject.global_permissions).to eq([])
      end
    end
  end
end
