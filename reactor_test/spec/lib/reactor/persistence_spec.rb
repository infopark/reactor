# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Obj do
  it "should include Reactor::Persistence::Base" do
    Obj.should include(Reactor::Persistence::Base)
  end

  it "should not be read-only" do
    Obj.new.should_not be_readonly
  end
end

describe Reactor::Persistence do

  describe '#release' do
    context "valid object" do
      let(:obj) { Obj.find_by_path('/valid_object_for_release') }
      before { obj.edit! }

      it "returns true" do
        obj.release.should be_true
      end

      it "releases the object" do
        obj.release
        obj.should be_released
      end
    end

    context "invalid object" do
      let(:obj) { Obj.find_by_path('/invalid_object_for_release') }
      before { obj.stub!(:valid?) { false } }

      it "returns false" do
        obj.release.should be_false
      end
    end

    context "object without working version" do
      let(:obj) { Obj.find_by_path('/invalid_object_for_release') }
      before { obj.stub!(:edited?) { false } }

      it "returns false" do
        obj.release.should be_false
      end
    end

    context "user lacks permission to release the object" do
      let(:obj) { Obj.find_by_path('/invalid_object_for_release') }
      before { obj.stub!(:permission) { double(:release? => false) } }
      it "returns false" do
        obj.release.should be_false
      end
    end
  end

  describe '#release!' do
    context "valid object" do
      let(:obj) { Obj.find_by_path('/valid_object_for_release') }
      before { obj.edit! }

      it "returns true" do
        obj.release!.should be_true
      end

      it "releases object" do
        obj.release!
        obj.should be_released
      end
    end

    context "invalid object" do
      let(:obj) { stub_model(Obj) }
      before { obj.stub!(:valid?) { false } }

      it "raises RecordInvalid exception" do
        expect { obj.release! }.to raise_exception(ActiveRecord::RecordInvalid)
      end
    end

    context "object without working version" do
      let(:obj) { stub_model(Obj) }
      before { obj.stub!(:edited?) { false } }

      it "raises AlreadyReleased exception" do
        expect { obj.release! }.to raise_exception(Reactor::AlreadyReleased)
      end
    end

    context "user lacks permission to release the object" do
      let(:obj) { stub_model(Obj) }
      before { obj.stub!(:permission) { double(:release? => false) } }
      it "raises NotPermitted exception" do
        expect { obj.release! }.to raise_exception(Reactor::NotPermitted)
      end
    end
  end

  describe '#take' do
    context "user is not the editor" do
      before do
        @user_name = 'normal_user'
        @group_name = 'normal_user_group'
        if Reactor::Cm::Group.exists?(@group_name)
          @group = Reactor::Cm::Group.get(@group_name)
        else
          @group = Reactor::Cm::Group.create(:name => @group_name)
        end

        if Reactor::Cm::User::Internal.exists?(@user_name)
          @user = Reactor::Cm::User::Internal.get(@user_name)
        else
          @user = Reactor::Cm::User::Internal.create(@user_name, @group_name)
        end
      end

      after do
        @user.delete!
        @group.delete!
      end

      before do
        @obj = Obj.create(:name => 'not_owned_by_root', :parent => '/', :obj_class => 'PlainObjClass')
        @obj.permission.grant(:write, @group_name)
        @obj.edit
        @obj.release

        Reactor::Sudo.su(@user_name) do
          @obj.edit!
        end
      end

      after do
        @obj.destroy
      end

      it "makes the user editor of the file" do
        @obj.editor.should_not == 'root'
        @obj.take
        @obj.editor.should == 'root'
      end
      it "returns true" do
        @obj.take.should be_true
      end
    end

    context "user is the editor" do
      before do
        Reactor::Session.instance.send(:user_name=, 'root')
        @obj = Obj.create(:name => 'not_owned_by_root', :parent => '/', :obj_class => 'PlainObjClass')
        @obj.edit
        @obj.take
        Reactor::Session.instance.send(:user_name=, 'root')
      end
      it "leaves the user as editor" do
        @obj.editor.should == 'root'
        @obj.take
        @obj.editor.should == 'root'
      end
      it "returns true" do
        @obj.take.should be_true
      end
    end

    context "the object has not been edited" do
      let(:obj) {stub_model(Obj)}
      before { obj.stub!(:edited?) {false} }
      it "returns false" do
        obj.take.should be_false
      end
    end

    context "user lacks permission to edit the object" do
      let(:obj) { stub_model(Obj) }
      before { obj.stub!(:permission) { double(:take? => false) } }
      it "returns false" do
        obj.take.should be_false
      end
    end
  end

  describe '#take!' do
    context "user is not the editor" do
      before do
        @user_name = 'normal_user'
        @group_name = 'normal_user_group'
        if Reactor::Cm::Group.exists?(@group_name)
          @group = Reactor::Cm::Group.get(@group_name)
        else
          @group = Reactor::Cm::Group.create(:name => @group_name)
        end

        if Reactor::Cm::User::Internal.exists?(@user_name)
          @user = Reactor::Cm::User::Internal.get(@user_name)
        else
          @user = Reactor::Cm::User::Internal.create(@user_name, @group_name)
        end
      end

      after do
        @user.delete!
        @group.delete!
      end

      before do
        @obj = Obj.create(:name => 'not_owned_by_root', :parent => '/', :obj_class => 'PlainObjClass')
        @obj.permission.grant(:write, @group_name)
        @obj.edit
        @obj.release

        Reactor::Sudo.su(@user_name) do
          @obj.edit!
        end
      end

      after do
        @obj.destroy
      end

      it "makes the user editor of the file" do
        @obj.editor.should_not == 'root'
        @obj.take!
        @obj.editor.should == 'root'
      end
      it "returns true" do
        @obj.take!.should be_true
      end
    end

    context "user is the editor" do
      before do
        Reactor::Session.instance.send(:user_name=, 'root')
        @obj = Obj.create(:name => 'not_owned_by_root', :parent => '/', :obj_class => 'PlainObjClass')
        @obj.edit
        @obj.take
        Reactor::Session.instance.send(:user_name=, 'root')
      end
      it "leaves the user as editor" do
        @obj.editor.should == 'root'
        @obj.take!
        @obj.editor.should == 'root'
      end
      it "returns true" do
        @obj.take!.should be_true
      end
    end

    context "the object has not been edited" do
      let(:obj) {stub_model(Obj)}
      before { obj.stub!(:edited?) {false} }
      it "raises NoWorkingVersion" do
        expect { obj.take! }.to raise_exception(Reactor::NoWorkingVersion)
      end
    end

    context "user lacks permission to edit the object" do
      let(:obj) { stub_model(Obj) }
      before { obj.stub!(:permission) { double(:take? => false) } }
      it "raises NotPermitted exception" do
        expect { obj.take! }.to raise_exception(Reactor::NotPermitted)
      end
    end
  end

  describe '#edit' do
    context "object does not have working version" do
      let(:obj) { Obj.find_by_path('/valid_object_for_edit') }
      before { obj.release }

      it "returns true" do
        obj.edit.should be_true
      end

      it "edits object" do
        obj.edit
        obj.should be_edited
      end
    end

    context "object does have working version" do
      let(:obj) { Obj.find_by_path('/valid_object_for_edit') }
      before { obj.edit }

      it "returns true" do
        obj.edit.should be_true
      end

      it "leaves object edited" do
        obj.edit
        obj.should be_edited
      end
    end

    context "user lacks permission to release the object" do
      let(:obj) { Obj.find_by_path('/valid_object_for_edit') }
      before { obj.stub!(:permission) { double(:edit? => false) } }
      it "returns false" do
        obj.edit.should be_false
      end
    end
  end

  describe '#edit!' do
    context "object does not have working version" do
      let(:obj) { Obj.find_by_path('/valid_object_for_edit') }
      before { obj.release }

      it "returns true" do
        obj.edit!.should be_true
      end

      it "edits object" do
        obj.edit!
        obj.should be_edited
      end
    end

    context "object does have working version" do
      let(:obj) { Obj.find_by_path('/valid_object_for_edit') }
      before { obj.edit }

      it "returns true" do
        obj.edit!.should be_true
      end

      it "leaves object edited" do
        obj.edit!
        obj.should be_edited
      end
    end

    context "user lacks permission to release the object" do
      let(:obj) { Obj.find_by_path('/valid_object_for_edit') }
      before { obj.stub!(:permission) { double(:edit? => false) } }
      it "returns false" do
        expect {obj.edit!}.to raise_exception(Reactor::NotPermitted)
      end
    end
  end

  context "when object exists" do
    before { @obj = Obj.last }

    describe '#new_record?' do
      it { @obj.new_record?.should be_false }
    end

    describe '#persisted?' do
      it { @obj.persisted?.should be_true }
    end

    describe '#destroyed?' do
      it { @obj.destroyed?.should be_false }
    end
  end

  context "when object does not exist" do
    before { @obj = Obj.new }

    describe '#new_record?' do
      it { @obj.new_record?.should be_true }
    end

    describe '#persisted?' do
      it { @obj.persisted?.should be_false }
    end

    describe '#destroyed?' do
      it { @obj.destroyed?.should be_false }
    end
  end

  context "when object is destroyed" do
    before do
      @obj = Obj.new
      @obj.destroy
    end

    describe '#new_record?' do
      it { @obj.new_record?.should be_false }
    end

    describe '#persisted?' do
      it { @obj.persisted?.should be_false }
    end

    describe '#destroyed?' do
      it { @obj.destroyed?.should be_true }
    end
  end

  describe '#delete' do
    before do
      class CallbackedObj < Obj
        before_destroy :before_destroy_callback
        after_destroy  :after_destroy_callback
        around_destroy :around_destroy_callback
        def before_destroy_callback ; end
        def after_destroy_callback  ; end
        def around_destroy_callback ; end
      end
    end
    it "freezes the object" do
      obj = Obj.new
      obj.delete
      obj.should be_frozen
    end

    it "doesn't run before callback" do
      obj = CallbackedObj.new
      obj.should_not_receive(:before_destroy_callback)
      obj.delete
    end

    it "doesn't run after callback" do
      obj = CallbackedObj.new
      obj.should_not_receive(:after_destroy_callback)
      obj.delete
    end

    it "doesn't run around callback" do
      obj = CallbackedObj.new
      obj.should_not_receive(:around_destroy_callback)
      obj.delete
    end

    context "when object is persisted" do
      let(:obj) {Obj.create(:name => 'object_to_delete', :parent => '/', :obj_class => 'PlainObjClass')}
      it "removes it from CM" do
        obj_id = obj.id
        obj.delete
        # Uncomment this line and comment the following in case specs are converted to VCR based ones
        #Reactor::Cm::Obj.should_not be_exists(obj_id)
        Obj.should_not be_exists(obj_id)
      end
    end
  end

  describe '#destroy' do
    before do
      class CallbackedObj < Obj
        before_destroy :before_destroy_callback
        after_destroy  :after_destroy_callback
        around_destroy :around_destroy_callback
        def before_destroy_callback ; end
        def after_destroy_callback  ; end
        def around_destroy_callback ; end
      end
    end
    it "freezes the object" do
      obj = Obj.new
      obj.destroy
      obj.should be_frozen
    end

    it "runs before callback" do
      obj = CallbackedObj.new
      obj.should_receive(:before_destroy_callback)
      obj.destroy
    end

    it "runs after callback" do
      obj = CallbackedObj.new
      obj.should_receive(:after_destroy_callback)
      obj.destroy
    end

    it "runs around callback" do
      obj = CallbackedObj.new
      obj.should_receive(:around_destroy_callback)
      obj.destroy
    end

    context "when object is persisted" do
      let(:obj) {Obj.create(:name => 'object_to_destroy', :parent => '/', :obj_class => 'PlainObjClass')}
      it "removes it from CM" do
        obj_id = obj.id
        obj.destroy
        # Uncomment this line and comment the following in case specs are converted to VCR based ones
        #Reactor::Cm::Obj.should_not be_exists(obj_id)
        Obj.should_not be_exists(obj_id)
      end
    end
  end

  describe '#reload' do
    pending
  end

  describe '#resolve_refs' do
    context "object without resolved refs" do
      let(:obj) {Obj.find_by_path('/object_without_resolved_refs')}
      it "resolves refs of the object" do
        obj_id = obj.id
        obj.resolve_refs
        pending("68")
        Reactor::Cm::Obj.get(obj_id).send(:get_content_attr_text, :blob).should match(/<a href="\.\.\/object_sure_to_exist\/index\.html">link<\/a>/)
      end

      it "returns true" do
        obj.resolve_refs.should be_true
      end
    end

    context "user lacks permissions" do
      let(:obj) {Obj.find_by_path('/object_without_resolved_refs2')}
      before {obj.stub!(:permission) {double(:write? => false)} }
      it "doesn't resolve refs" do
        obj_id = obj.id
        obj.resolve_refs
        Reactor::Cm::Obj.get(obj_id).send(:get_content_attr_text, :blob).should_not match(/<a href="\.\.\/object_sure_to_exist\/index\.html">link<\/a>/)
      end
      it "returns false" do
        obj.resolve_refs.should be_false
      end
    end
  end

  describe '.create' do
    after { @obj.destroy }
    it "creates and object and returns (matching) Obj instance" do
      @obj = Obj.create(:name => 'creation_test', :parent => '/', :obj_class => 'PlainObjClass')
      Obj.should be_exists(@obj.id)
      @obj.should be_kind_of(Obj)
    end
  end

  describe '#save' do
    pending
  end

  describe '#save!' do
    after { @obj.destroy }
    it "stores channels" do
      @obj = Obj.create(:name => 'channels_test', :parent => '/', :obj_class => 'PlainObjClass')
      @obj.channels = "my.simple.channel" # @obj.channels = ["my.simple.channel"] # is more valid!
      @obj.save!
      Obj.find(@obj.id).channels.should eq(['my.simple.channel'])
    end
  end

  describe '#reasons_for_incomplete_state' do
    context "without any reasons" do
      before { @obj = Obj.create(:parent => '/', :name => 'no_reasons_for_incomplete_state', :obj_class => 'ReleasableClass')}
      after { @obj.destroy }
      it "returns an empty collection" do
        @obj.reasons_for_incomplete_state.should be_empty
      end
    end

    context "with reasons" do
      before { @obj = Obj.create(:parent => '/', :name => 'with_reasons_for_incomplete_state', :obj_class => 'UnreleasableClass')}
      after { @obj.destroy }
      it "returns an empty collection" do
        @obj.reasons_for_incomplete_state.should_not be_empty
        @obj.reasons_for_incomplete_state.should have_at_least(1).items
      end
    end
  end
end
