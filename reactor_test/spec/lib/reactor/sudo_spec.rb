require 'spec_helper'

describe Reactor::Sudo do
  describe '.su' do
    before do
      Reactor::Configuration.xml_access[:username] = 'root'
      Reactor::Cm::User::Internal.create('otherUser', 'not_root_group') unless  Reactor::Cm::User::Internal.exists?('otherUser')
    end

    after do
      Reactor::Configuration.xml_access[:username] = 'root'
      Reactor::Cm::User::Internal.delete!('otherUser')
    end

    it "temporarily changes the user" do
      Reactor::Configuration.xml_access[:username].should == 'root'
      Reactor::Sudo.su('otherUser') do
        Reactor::Configuration.xml_access[:username].should == 'otherUser'
      end
      Reactor::Configuration.xml_access[:username].should == 'root'
    end

    it "changes the user back even when exceptions raised" do
      begin
        Reactor::Configuration.xml_access[:username].should == 'root'
        Reactor::Sudo.su('otherUser') do
          Reactor::Configuration.xml_access[:username].should == 'otherUser'
          raise RuntimeError, "I just want to be sure"
        end
      rescue => e
      end

      Reactor::Configuration.xml_access[:username].should == 'root'
    end
  end
end