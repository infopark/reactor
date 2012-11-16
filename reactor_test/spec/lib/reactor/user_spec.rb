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

end
