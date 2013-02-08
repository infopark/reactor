# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Reactor::Cm::User::Internal do
  it { described_class.primary_key == 'login' }

  it "'root' user should always exist" do
    described_class.should be_exists('root')
  end

  it "'nonexistingUserForSure' should not exist" do
    described_class.should_not be_exists('nonexistingUserForSure')
  end

  context "'root' user" do
    let(:user) { described_class.get('root') }

    it { user.login.should == 'root' }
    it { user.should be_super_user }
    it { user.groups.should have_at_least(1).things }
    it { user.default_group.should_not be_empty }
  end

  describe '.create' do
    # Make sure the test environment has been prepared corectly
    it { Reactor::Cm::Group.should be_exists('not_root_group') }
    before do
      described_class.delete!('userToCreate') if described_class.exists?('userToCreate')
    end
    it "creates a user" do
      described_class.should_not be_exists('userToCreate')
      described_class.create('userToCreate', 'not_root_group')
      described_class.should be_exists('userToCreate')
      described_class.delete!('userToCreate')
    end
  end

  describe '.delete!' do
    it "delete!s existing user" do
      described_class.create('userToCreate', 'not_root_group') unless described_class.exists?('userToCreate')
      described_class.should be_exists('userToCreate')
      described_class.delete!('userToCreate')
      described_class.should_not be_exists('userToCreate')
    end
  end

  describe "changing user's realName" do
    before do
      if described_class.exists?('userWithNameToChange')
        @user = described_class.get('userWithNameToChange')
        @user.real_name = 'NOT Hans Schmidt'
        @user.save!
      else
        @user = described_class.create('userWithNameToChange', 'not_root_group')
      end
    end
    after {@user.delete!}
    it "should change the real name" do
      @user.real_name.should_not == 'Hans Schmidt'
      @user.real_name = 'Hans Schmidt'
      @user.save!
      @user.reload
      @user.real_name.should == 'Hans Schmidt'
    end
  end
end
