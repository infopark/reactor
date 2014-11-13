# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Obj do
  it "should include Reactor::Persistence::Base" do
    expect(Obj).to include(Reactor::Persistence::Base)
  end

  it "should not be read-only" do
    expect(Obj.new).not_to be_readonly
  end
end

describe Reactor::Persistence do

  describe 'save with custom getter' do
    after do
      Obj.where("path LIKE '/stupidgetter%'").each(&:destroy)
    end

    it 'works properly' do
      o = TestClassWithCustomAttributes.create(:parent => '/', :name => 'stupidgetter')
      o.test_attr_text = 'test1'
      o.test_attr_linklist = [{:url => 'http://google.com'}]
      o.save!
      expect(o.test_attr_text).to eq('test1')
      expect(o.test_attr_linklist.first.url).to eq('http://google.com')

      allow(o).to receive(:test_attr_text) { 'hahah, no' }
      allow(o).to receive(:test_attr_linklist) { 'whatever' }

      o.test_attr_text = 'test2'
      o.test_attr_linklist = [{:url => 'http://yahoo.com'}]

      o.save!
      expect(Obj.find(o.id).test_attr_text).to eq('test2')
      expect(Obj.find(o.id).test_attr_linklist.first.url).to eq('http://yahoo.com')
    end
  end

  describe 'changing obj class' do
    after do
      Obj.where("path LIKE '/changeobjclass%'").each(&:destroy)
    end

    it 'does not raise exception' do
      o = TestClassWithCustomAttributes.create(:parent => '/', :name => 'changeobjclass')
      o.obj_class = 'PlainObjClass'
      expect { o.save! }.not_to raise_exception
    end
  end

  describe 'setting permalink' do
    after do
      Obj.where("path LIKE '/setpermalink%'").each(&:destroy)
    end

    it 'does not create a working version' do
      o = TestClassWithCustomAttributes.create(:parent => '/', :name => 'setpermalink', :test_attr_linklist => [{:url => 'http://google.com'}])
      o.release!
      o.permalink = 'setpermalink123'

      expect(o).not_to be_edited

      o.save!

      expect(o).not_to be_edited
    end

    it 'does create working version when setting links' do
      o = TestClassWithCustomAttributes.create(:parent => '/', :name => 'setpermalink', :test_attr_linklist => [{:url => 'http://google.com'}])
      o.release!
      o.permalink = 'setpermalink123'
      o.test_attr_linklist = [{:url => 'http://yahoo.com'}]

      expect(o).not_to be_edited

      o.save!

      expect(o).to be_edited
      expect(o.test_attr_linklist.first.url).to eq('http://yahoo.com')
      expect(o.test_attr_linklist.size).to eq(1)
    end

    it 'does create working version when setting content' do
      o = TestClassWithCustomAttributes.create(:parent => '/', :name => 'setpermalink', :test_attr_html => '<a href="http://google.com">http://google.com</a>')

      o.release!
      o.permalink = 'setpermalink123'

      expect(o).not_to be_edited

      o.save!

      expect(o).to be_edited

      # this validates links
      o.release!
      expect(o).not_to be_edited
    end
  end

  context "active record cache" do
    describe "reload" do
      before do
        @cachex = Obj.create(:parent => '/', :name => 'cachetest', :obj_class => 'TestClassWithCustomAttributes', :body => 'a')
      end
      after do
        @cachex.destroy
      end

      it "isn't affected by the cache" do
        first_copy = @cachex

        Obj.cache do
          second_copy = Obj.find(first_copy.id)
          first_copy.body = 'b'
          first_copy.save!
          expect(second_copy.body).to eq('a')
          second_copy.reload
          expect(second_copy.body).to eq('b')
        end

      end
    end
  end

  describe '#release' do
    context "valid object" do
      let(:obj) { Obj.find_by_path('/valid_object_for_release') }
      before { obj.edit! }

      it "returns true" do
        expect(obj.release).to be_truthy
      end

      it "releases the object" do
        obj.release
        expect(obj).to be_released
      end
    end

    context "invalid object" do
      let(:obj) { Obj.find_by_path('/invalid_object_for_release') }
      before { allow(obj).to receive(:valid?) { false } }

      it "returns false" do
        expect(obj.release).to be_falsey
      end
    end

    context "object without working version" do
      let(:obj) { Obj.find_by_path('/invalid_object_for_release') }
      before { allow(obj).to receive(:edited?) { false } }

      it "returns false" do
        expect(obj.release).to be_falsey
      end
    end

    context "user lacks permission to release the object" do
      let(:obj) { Obj.find_by_path('/invalid_object_for_release') }
      before { allow(obj).to receive(:permission) { double(:release? => false) } }
      it "returns false" do
        expect(obj.release).to be_falsey
      end
    end
  end

  describe '#release!' do
    context "valid object" do
      let(:obj) { Obj.find_by_path('/valid_object_for_release') }
      before { obj.edit! }

      it "returns true" do
        expect(obj.release!).to be_truthy
      end

      it "releases object" do
        obj.release!
        expect(obj).to be_released
      end
    end

    context "invalid object" do
      let(:obj) { stub_model(Obj) }
      before { allow(obj).to receive(:valid?) { false } }

      it "raises RecordInvalid exception" do
        expect { obj.release! }.to raise_exception(ActiveRecord::RecordInvalid)
      end
    end

    context "object without working version" do
      let(:obj) { stub_model(Obj) }
      before { allow(obj).to receive(:edited?) { false } }

      it "raises AlreadyReleased exception" do
        expect { obj.release! }.to raise_exception(Reactor::AlreadyReleased)
      end
    end

    context "user lacks permission to release the object" do
      let(:obj) { stub_model(Obj) }
      before { allow(obj).to receive(:permission) { double(:release? => false) } }
      it "raises NotPermitted exception" do
        expect { obj.release! }.to raise_exception(Reactor::NotPermitted)
      end
    end
  end

  [:revert, :revert!].each do |method|
    describe "#{method}" do
      before do
        @obj = TestClassWithCustomAttributes.create(:name => 'no_working_version', :parent => '/')
      end
      after do
        @obj.destroy
      end

      context "object with working version" do
        before do
          @obj.body = 'There is no need to be afraid, Kemp. We are partners.'
          @obj.save!
        end

        it "clears attributes" do
          @obj.send(method)
          expect(@obj.body).to be_blank
          expect(Obj.find(@obj.obj_id).body).to be_blank
        end
      end

      context "released object with working version" do
        before do
          @obj.body = '1'
          @obj.save!
          @obj.release!
          @obj.body = '2'
          @obj.save!
        end

        it "resets attributes" do
          @obj.send(method)
          expect(@obj.body).to eq('1')
        end
      end

      it "returns true" do
        expect(@obj.send(method)).to be_truthy
      end

      it "reloads object" do
        expect(@obj).to receive(:reload)
        @obj.send(method)
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
        expect(@obj.editor).not_to eq('root')
        @obj.take
        expect(@obj.editor).to eq('root')
      end
      it "returns true" do
        expect(@obj.take).to be_truthy
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
        expect(@obj.editor).to eq('root')
        @obj.take
        expect(@obj.editor).to eq('root')
      end
      it "returns true" do
        expect(@obj.take).to be_truthy
      end
    end

    context "the object has not been edited" do
      let(:obj) {stub_model(Obj)}
      before { allow(obj).to receive(:edited?) {false} }
      it "returns false" do
        expect(obj.take).to be_falsey
      end
    end

    context "user lacks permission to edit the object" do
      let(:obj) { stub_model(Obj) }
      before { allow(obj).to receive(:permission) { double(:take? => false) } }
      it "returns false" do
        expect(obj.take).to be_falsey
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
        expect(@obj.editor).not_to eq('root')
        @obj.take!
        expect(@obj.editor).to eq('root')
      end
      it "returns true" do
        expect(@obj.take!).to be_truthy
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
        expect(@obj.editor).to eq('root')
        @obj.take!
        expect(@obj.editor).to eq('root')
      end
      it "returns true" do
        expect(@obj.take!).to be_truthy
      end
    end

    context "the object has not been edited" do
      let(:obj) {stub_model(Obj)}
      before { allow(obj).to receive(:edited?) {false} }
      it "raises NoWorkingVersion" do
        expect { obj.take! }.to raise_exception(Reactor::NoWorkingVersion)
      end
    end

    context "user lacks permission to edit the object" do
      let(:obj) { stub_model(Obj) }
      before { allow(obj).to receive(:permission) { double(:take? => false) } }
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
        expect(obj.edit).to be_truthy
      end

      it "edits object" do
        obj.edit
        expect(obj).to be_edited
      end
    end

    context "object does have working version" do
      let(:obj) { Obj.find_by_path('/valid_object_for_edit') }
      before { obj.edit }

      it "returns true" do
        expect(obj.edit).to be_truthy
      end

      it "leaves object edited" do
        obj.edit
        expect(obj).to be_edited
      end
    end

    context "user lacks permission to release the object" do
      let(:obj) { Obj.find_by_path('/valid_object_for_edit') }
      before { allow(obj).to receive(:permission) { double(:edit? => false) } }
      it "returns false" do
        expect(obj.edit).to be_falsey
      end
    end
  end

  describe '#edit!' do
    context "object does not have working version" do
      let(:obj) { Obj.find_by_path('/valid_object_for_edit') }
      before { obj.release }

      it "returns true" do
        expect(obj.edit!).to be_truthy
      end

      it "edits object" do
        obj.edit!
        expect(obj).to be_edited
      end
    end

    context "object does have working version" do
      let(:obj) { Obj.find_by_path('/valid_object_for_edit') }
      before { obj.edit }

      it "returns true" do
        expect(obj.edit!).to be_truthy
      end

      it "leaves object edited" do
        obj.edit!
        expect(obj).to be_edited
      end
    end

    context "user lacks permission to release the object" do
      let(:obj) { Obj.find_by_path('/valid_object_for_edit') }
      before { allow(obj).to receive(:permission) { double(:edit? => false) } }
      it "returns false" do
        expect {obj.edit!}.to raise_exception(Reactor::NotPermitted)
      end
    end
  end

  context "when object exists" do
    before { @obj = Obj.last }

    describe '#new_record?' do
      it { expect(@obj.new_record?).to be_falsey }
    end

    describe '#persisted?' do
      it { expect(@obj.persisted?).to be_truthy }
    end

    describe '#destroyed?' do
      it { expect(@obj.destroyed?).to be_falsey }
    end
  end

  context "when object does not exist" do
    before { @obj = Obj.new }

    describe '#new_record?' do
      it { expect(@obj.new_record?).to be_truthy }
    end

    describe '#persisted?' do
      it { expect(@obj.persisted?).to be_falsey }
    end

    describe '#destroyed?' do
      it { expect(@obj.destroyed?).to be_falsey }
    end
  end

  context "when object is destroyed" do
    before do
      @obj = Obj.new
      @obj.destroy
    end

    describe '#new_record?' do
      it { expect(@obj.new_record?).to be_falsey }
    end

    describe '#persisted?' do
      it { expect(@obj.persisted?).to be_falsey }
    end

    describe '#destroyed?' do
      it { expect(@obj.destroyed?).to be_truthy }
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
      expect(obj).to be_frozen
    end

    it "doesn't run before callback" do
      obj = CallbackedObj.new
      expect(obj).not_to receive(:before_destroy_callback)
      obj.delete
    end

    it "doesn't run after callback" do
      obj = CallbackedObj.new
      expect(obj).not_to receive(:after_destroy_callback)
      obj.delete
    end

    it "doesn't run around callback" do
      obj = CallbackedObj.new
      expect(obj).not_to receive(:around_destroy_callback)
      obj.delete
    end

    context "when object is persisted" do
      let(:obj) {Obj.create(:name => 'object_to_delete', :parent => '/', :obj_class => 'PlainObjClass')}
      it "removes it from CM" do
        obj_id = obj.id
        obj.delete
        # Uncomment this line and comment the following in case specs are converted to VCR based ones
        #Reactor::Cm::Obj.should_not be_exists(obj_id)
        expect(Obj).not_to be_exists(obj_id)
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
      expect(obj).to be_frozen
    end

    it "runs before callback" do
      obj = CallbackedObj.new
      expect(obj).to receive(:before_destroy_callback)
      obj.destroy
    end

    it "runs after callback" do
      obj = CallbackedObj.new
      expect(obj).to receive(:after_destroy_callback)
      obj.destroy
    end

    it "runs around callback" do
      obj = CallbackedObj.new
      expect(obj).to receive(:around_destroy_callback)
      obj.destroy
    end

    context "when object is persisted" do
      let(:obj) {Obj.create(:name => 'object_to_destroy', :parent => '/', :obj_class => 'PlainObjClass')}
      it "removes it from CM" do
        obj_id = obj.id
        obj.destroy
        # Uncomment this line and comment the following in case specs are converted to VCR based ones
        #Reactor::Cm::Obj.should_not be_exists(obj_id)
        expect(Obj).not_to be_exists(obj_id)
      end
    end
  end

  describe '#reload' do
    skip
  end

  describe '#resolve_refs' do
    context "object without resolved refs" do
      let(:obj) {Obj.find_by_path('/object_without_resolved_refs')}
      it "resolves refs of the object" do
        obj_id = obj.id
        obj.resolve_refs
        skip("68")
        expect(Reactor::Cm::Obj.get(obj_id).send(:get_content_attr_text, :blob)).to match(/<a href="\.\.\/object_sure_to_exist\/index\.html">link<\/a>/)
      end

      it "returns true" do
        expect(obj.resolve_refs).to be_truthy
      end
    end

    context "user lacks permissions" do
      let(:obj) {Obj.find_by_path('/object_without_resolved_refs2')}
      before {allow(obj).to receive(:permission) {double(:write? => false)} }
      it "doesn't resolve refs" do
        obj_id = obj.id
        obj.resolve_refs
        expect(Reactor::Cm::Obj.get(obj_id).send(:get_content_attr_text, :blob)).not_to match(/<a href="\.\.\/object_sure_to_exist\/index\.html">link<\/a>/)
      end
      it "returns false" do
        expect(obj.resolve_refs).to be_falsey
      end
    end
  end

  describe '.create' do
    after { @obj.destroy }
    it "creates and object and returns (matching) Obj instance" do
      @obj = Obj.create(:name => 'creation_test', :parent => '/', :obj_class => 'PlainObjClass')
      expect(Obj).to be_exists(@obj.id)
      expect(@obj).to be_kind_of(Obj)
    end
  end

  describe '#save' do
    skip
  end

  describe '#save!' do
    after { @obj.destroy }
    it "stores channels" do
      @obj = Obj.create(:name => 'channels_test', :parent => '/', :obj_class => 'PlainObjClass')
      @obj.channels = "my.simple.channel" # @obj.channels = ["my.simple.channel"] # is more valid!
      @obj.save!
      expect(Obj.find(@obj.id).channels).to eq(['my.simple.channel'])
    end
  end

  describe '#reasons_for_incomplete_state' do
    context "without any reasons" do
      before { @obj = Obj.create(:parent => '/', :name => 'no_reasons_for_incomplete_state', :obj_class => 'ReleasableClass')}
      after { @obj.destroy }
      it "returns an empty collection" do
        expect(@obj.reasons_for_incomplete_state).to be_empty
      end
    end

    context "with reasons" do
      before { @obj = Obj.create(:parent => '/', :name => 'with_reasons_for_incomplete_state', :obj_class => 'UnreleasableClass')}
      after { @obj.destroy }
      it "returns an empty collection" do
        expect(@obj.reasons_for_incomplete_state).not_to be_empty
        expect(@obj.reasons_for_incomplete_state.size).to be >= 1
      end
    end
  end
end
