require 'spec_helper'

describe TrivialController do
  describe '#rsession' do
    it 'is a Reactor::Session' do
      subject.rsession.should be_kind_of(Reactor::Session)
    end
  end

  describe 'GET nothing' do
    it 'calls rsession_auth' do
      subject.should_receive :rsession_auth

      get :nothing
    end
  end

  describe '#rsession_auth' do
    it "tries to login rsession" do
      request.cookies['JSESSIONID'] = '==secret=='
      subject.rsession.should_receive(:login).with('==secret==')

      get :nothing
    end

    it 'contains hack for wrongly escaped cookies' do
      request.cookies['JSESSIONID'] = '== secret =='
      subject.rsession.should_receive(:login).with('==+secret+==')

      get :nothing
    end

    context "without JSESSIONID set" do
      it "calls destroy on rsession" do
        subject.rsession.should_receive(:destroy)

        get :nothing
      end
    end

    context "in live mode" do
      it "calls destroy on rsession" do
        request.cookies['JSESSIONID'] = '==secret=='
        RailsConnector::Configuration.stub(:mode) == :live

        subject.rsession.should_receive(:destroy)

        get :nothing
      end
    end
  end
end