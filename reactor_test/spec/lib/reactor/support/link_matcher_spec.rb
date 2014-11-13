# -*- encoding : utf-8 -*-
require 'spec_helper'

module Reactor
  module Support
    describe LinkMatcher do
      context "for when object with matching id-route exists" do
        let(:link) { LinkMatcher.new('/1234/my_object') }
        before do
          allow(Obj).to receive(:exists?) {|id| id == 1234 }
          allow(Obj).to receive(:find) {|id| double(:path => '/matching/path') if id == 1234}
        end

        describe '#recognized?' do
          it "recognizes the url" do
            expect(link).to be_recognized
          end
        end

        describe '#rewrite_url' do
          it "returns matching path" do
            expect(link.rewrite_url).to eq('/matching/path')
          end
        end
      end

      context "for when object with matching id-route exists, link with anchor (url fragment)" do
        let(:link) { LinkMatcher.new('/1234/my_object#anchor') }
        before do
          allow(Obj).to receive(:exists?) {|id| id == 1234 }
          allow(Obj).to receive(:find) {|id| double(:path => '/matching/path') if id == 1234}
        end

        describe '#recognized?' do
          it "recognizes the url" do
            expect(link).to be_recognized
          end
        end

        describe '#rewrite_url' do
          it "returns matching path" do
            expect(link.rewrite_url).to eq('/matching/path#anchor')
          end
        end
      end

      context "for when object with matching id-route exists, link with anchor (url fragment) and GET query string" do
        let(:link) { LinkMatcher.new('/1234/my_object?param1=val1&param2=val2#anchor') }
        before do
          allow(Obj).to receive(:exists?) {|id| id == 1234 }
          allow(Obj).to receive(:find) {|id| double(:path => '/matching/path') if id == 1234}
        end

        describe '#recognized?' do
          it "recognizes the url" do
            expect(link).to be_recognized
          end
        end

        describe '#rewrite_url' do
          it "returns matching path" do
            expect(link.rewrite_url).to eq('/matching/path?param1=val1&param2=val2#anchor')
          end
        end
      end
    end
  end
end
