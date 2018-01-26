require 'spec_helper'

describe 'Reactor groups' do
  before { Reactor::Cm::Group.get('testingGroup').delete! rescue nil }
  after  { Reactor::Cm::Group.get('testingGroup').delete! rescue nil }

  before { Reactor::Cm::Group.create({
    name: 'testingGroup', users: ['not_root'],
    real_name: 'THE REAL NAME OF THE TESTING GROUP', owner: 'root'
  })}

  subject { Reactor::Cm::Group.get('testingGroup') }

  specify do
    expect(subject.user?('root')).to be_falsey
    expect(subject.user?('not_root')).to be_truthy
    expect(subject.name).to eq('testingGroup')
    expect(subject.owner).to eq('root')
    expect(subject.display_title).to eq('THE REAL NAME OF THE TESTING GROUP')
  end

  specify do
    expect(Reactor::Cm::Group.all.map(&:name)).to include('testingGroup')
  end

  describe 'Group proxy' do
    subject { Reactor::Cm::EditorialGroup.get('testingGroup') }

    specify do
      expect(subject.user?('root')).to be_falsey
      expect(subject.user?('not_root')).to be_truthy
      expect(subject.name).to eq('testingGroup')
      expect(subject.owner).to eq('root')
      expect(subject.display_title).to eq('THE REAL NAME OF THE TESTING GROUP')
    end

    specify do
      expect(Reactor::Cm::EditorialGroup.all.map(&:name)).to include('testingGroup')
    end
  end
end
