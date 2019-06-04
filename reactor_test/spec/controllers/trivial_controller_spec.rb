# frozen_string_literal: true

require 'spec_helper'

describe TrivialController, type: :controller do
  describe '#rsession' do
    it 'is a Reactor::Session' do
      expect(subject.rsession).to be_kind_of(Reactor::Session)
    end
  end

  describe 'GET nothing' do
    it 'calls rsession_auth' do
      expect(subject).to receive :rsession_auth

      get :nothing
    end
  end

  describe '#rsession_auth' do
    it "tries to login rsession" do
      request.cookies['JSESSIONID'] = '==secret=='
      expect(subject.rsession).to receive(:login).with('==secret==')

      get :nothing
    end

    it 'contains hack for wrongly escaped cookies' do
      request.cookies['JSESSIONID'] = '== secret =='
      expect(subject.rsession).to receive(:login).with('==+secret+==')

      get :nothing
    end

    context "without JSESSIONID set" do
      it "calls destroy on rsession" do
        expect(subject.rsession).to receive(:destroy)

        get :nothing
      end
    end

    context "in live mode" do
      it "calls destroy on rsession" do
        request.cookies['JSESSIONID'] = '==secret=='
        allow(RailsConnector::Configuration).to receive(:mode).and_return(:live)

        expect(subject.rsession).to receive(:destroy)

        get :nothing
      end
    end
  end
end
