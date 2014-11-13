# -*- encoding : utf-8 -*-
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
      expect(Reactor::Configuration.xml_access[:username]).to eq('root')
      Reactor::Sudo.su('otherUser') do
        expect(Reactor::Configuration.xml_access[:username]).to eq('otherUser')
      end
      expect(Reactor::Configuration.xml_access[:username]).to eq('root')
    end

    it "changes the user back even when exceptions raised" do
      begin
        expect(Reactor::Configuration.xml_access[:username]).to eq('root')
        Reactor::Sudo.su('otherUser') do
          expect(Reactor::Configuration.xml_access[:username]).to eq('otherUser')
          raise RuntimeError, "I just want to be sure"
        end
      rescue => e
      end

      expect(Reactor::Configuration.xml_access[:username]).to eq('root')
    end
  end
end
