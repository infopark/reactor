require 'spec_helper'

describe Reactor::Session do
  subject { described_class.instance }

  it 'has three observers' do
    subject.count_observers.should eq(3)
  end

  specify 'changing name notifies observers' do
    subject.should_receive(:notify_observers).with('non_root_user', true)
    subject.user_name = 'non_root_user'
  end

  describe 'marshalling the object does not lose neither session_id nor user_name nor observers' do

    before do
      before_marshal = subject
      before_marshal.user_name = 'non_root_user'
      before_marshal.send(:session_id=, 'sssssession')

      mashalled = Marshal.dump(before_marshal)

      # reset singleton
      Singleton.__init__(described_class) if described_class < Singleton

      @after_marshal = Marshal.load(mashalled)
    end

    specify do
      @after_marshal.user_name.should eq('non_root_user')
      @after_marshal.session_id.should eq('sssssession')
      @after_marshal.count_observers.should eq(3)
    end
  end

  describe 'demarshalling the object sets access credentials' do
    after do
      Reactor::Configuration.xml_access[:username] = 'root'
    end

    specify do
      before_marshal = subject
      before_marshal.user_name = 'non_root_user'
      before_marshal.send(:session_id=, 'sssssession')

      mashalled = Marshal.dump(before_marshal)

      # reset singleton
      Singleton.__init__(described_class) if described_class < Singleton

      Reactor::Configuration.xml_access[:username] = 'root'

      @after_marshal = Marshal.load(mashalled)

      Reactor::Configuration.xml_access[:username].should eq(@after_marshal.user_name)
    end
  end
end
