# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Blob ticket handling" do
  before :all do
    container = Reactor::Cm::Obj.create('blob_ticket_handling', '/', 'PlainObjClass')
  end

  after :all do
    ::Obj.where('path LIKE "/blob_ticket_handling%"').order('path DESC').each(&:destroy)
  end

  let(:content_type) { 'pdf' }
  let(:target_blob_fingerprint) { Obj.find(target.obj_id).blob }
  let(:source_blob_fingerprint) { Obj.find(source.obj_id).blob }

  let(:edited_content) { 'edited' * 2_000 }
  let(:released_content) { 'released' * 2_000 }

  let(:source) do
    Reactor::Cm::Obj.create('source', '/blob_ticket_handling', 'Resource').tap do |obj|
      obj.upload(released_content, content_type)
      obj.save!
      obj.release!
      obj.upload(edited_content, content_type)
      obj.save!
    end
  end

  let(:target) do
    Reactor::Cm::Obj.create('source', '/blob_ticket_handling', 'Resource').tap do |obj|
    end
  end

  context "with a small blob ( < tuning.minStreamingDataLength )" do
    let(:edited_content) { 'edited' }
    let(:released_content) { 'released' }

    it "raises BlobTooSmallError" do
      expect { source.blob_ticket_id('edited') }.to raise_error(Reactor::Cm::BlobTooSmallError)
      expect { source.blob_ticket_id('released') }.to raise_error(Reactor::Cm::BlobTooSmallError)
    end
  end

  context "copying released content" do
    it "copies the reference" do
      blob_ticket_id = source.blob_ticket_id('released') 
      target.set(:blob, {blob_ticket_id => {encoding: 'stream'}})
      target.set(:contentType, content_type)
      expect { target.save! }.not_to raise_error
    end

    it "does not change when source changes" do
      target.set(:blob, {source.blob_ticket_id('released') => {encoding: 'stream'}})
      target.set(:contentType, content_type)
      target.save!
      target.set(:blob, {'overwritten'=>{encoding: 'plain'}})
      expect { target.save! }.not_to change { source.get('blob') }
      expect(target.get('blob')).to eq('overwritten')
    end
  end

  context "copying edited content" do

    it "copies the reference" do
      target.set(:blob, {source.blob_ticket_id('edited') => {encoding: 'stream'}})
      target.set(:contentType, content_type)
      expect { target.save! }.not_to raise_error
      # NOTE: this isn't true for CM < 6.8
      expect(target_blob_fingerprint).to eq(source_blob_fingerprint)
    end

    it "does not change when source changes" do
      target.set(:blob, {source.blob_ticket_id('edited') => {encoding: 'stream'}})
      target.set(:contentType, content_type)
      target.save!
      target.set(:blob, {'overwritten'=>{encoding: 'plain'}})
      expect { target.save! }.not_to change { source.get('blob') }
      expect(target.get('blob')).to eq('overwritten')
    end
  end

  context "accessing edited content when none exists" do
    let(:without_edited_content) do
      Reactor::Cm::Obj.create('without_edited_content', '/blob_ticket_handling', 'Resource').tap do |obj|
        obj.upload('released-only', content_type)
        obj.save!
        obj.release!
      end
    end

    it "raises an error" do 
      expect { without_edited_content.blob_ticket_id('edited') }.to raise_error(Reactor::Cm::XmlRequestError)
    end
  end

  context "accessing released content when none exists" do
    let(:without_released_content) do
      Reactor::Cm::Obj.create('without_released_content', '/blob_ticket_handling', 'Resource').tap do |obj|
        obj.upload('edited-only', content_type)
        obj.save!
      end
    end

    it "raises an error" do
      expect { without_released_content.blob_ticket_id('released') }.to raise_error(Reactor::Cm::XmlRequestError)
    end
  end
end
