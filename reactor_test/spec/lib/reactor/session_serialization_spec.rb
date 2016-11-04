require 'spec_helper'

describe Reactor::Session do
  subject { described_class.instance }

  it 'has three observers' do
    expect(subject.count_observers).to eq(3)
  end

  specify 'changing name notifies observers' do
    expect(subject).to receive(:notify_observers).with('non_root_user', true)
    subject.user_name = 'non_root_user'
  end

  describe 'marshalling the object does not lose neither session_id nor user_name nor observers' do

    before do
      before_marshal = subject
      before_marshal.user_name = 'non_root_user'
      before_marshal.send(:set_session_id, 'sssssession')

      mashalled = Marshal.dump(before_marshal)

      # reset singleton
      Singleton.__init__(described_class) if described_class < Singleton

      @after_marshal = Marshal.load(mashalled)
    end

    specify do
      expect(@after_marshal.user_name).to eq('non_root_user')
      expect(@after_marshal.session_id).to eq('sssssession')
      expect(@after_marshal.count_observers).to eq(3)
    end
  end

  describe 'demarshalling the object sets access credentials' do
    after do
      Reactor::Configuration.xml_access[:username] = 'root'
    end

    specify do
      before_marshal = subject
      before_marshal.user_name = 'non_root_user'
      before_marshal.send(:set_session_id, 'sssssession')

      mashalled = Marshal.dump(before_marshal)

      # reset singleton
      Singleton.__init__(described_class) if described_class < Singleton

      Reactor::Configuration.xml_access[:username] = 'root'

      @after_marshal = Marshal.load(mashalled)

      expect(Reactor::Configuration.xml_access[:username]).to eq(@after_marshal.user_name)
    end
  end
end
