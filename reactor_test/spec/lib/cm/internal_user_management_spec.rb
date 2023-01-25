# frozen_string_literal: true

require 'spec_helper'

describe Reactor::Cm::User::Internal do
  it { described_class.primary_key == 'login' }

  it "'root' user should always exist" do
    expect(described_class).to be_exists('root')
  end

  it "'nonexistingUserForSure' should not exist" do
    expect(described_class).not_to be_exists('nonexistingUserForSure')
  end

  context "'root' user" do
    let(:user) { described_class.get('root') }

    it { expect(user.login).to eq('root') }
    it { expect(user).to be_super_user }
    it { expect(user.groups.size).to be >= 1 }
    it { expect(user.default_group).not_to be_empty }
  end

  describe '.create' do
    # Make sure the test environment has been prepared corectly
    it { expect(Reactor::Cm::Group).to be_exists('not_root_group') }
    before do
      described_class.delete!('userToCreate') if described_class.exists?('userToCreate')
    end
    after do
      described_class.delete!('userToCreate') if described_class.exists?('userToCreate')
    end
    it "creates a user" do
      expect(described_class).not_to be_exists('userToCreate')
      described_class.create('userToCreate', 'not_root_group')
      expect(described_class).to be_exists('userToCreate')
      described_class.delete!('userToCreate')
    end
  end

  describe '.delete!' do
    it "delete!s existing user" do
      described_class.create('userToCreate', 'not_root_group') unless described_class.exists?('userToCreate')
      expect(described_class).to be_exists('userToCreate')
      described_class.delete!('userToCreate')
      expect(described_class).not_to be_exists('userToCreate')
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
      expect(@user.real_name).not_to eq('Hans Schmidt')
      @user.real_name = 'Hans Schmidt'
      @user.save!
      @user.reload
      expect(@user.real_name).to eq('Hans Schmidt')
      expect(described_class.get(@user.login).real_name).to eq('Hans Schmidt')
    end
  end

  describe "changing user's password" do
    before do
      if described_class.exists?('userWithPasswordToChange')
        @user = described_class.get('userWithPasswordToChange')
        @user.save!
      else
        @user = described_class.create('userWithPasswordToChange', 'not_root_group')
      end
    end
    after {@user.delete!}

    it "should change the password" do
      expect(@user.has_password?('the-password')).to be_falsey
      @user.change_password('the-password')
      expect(@user.has_password?('the-password')).to be_truthy
    end
  end

end
