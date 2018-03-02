require 'spec_helper'

describe Obj do
  it "should include Reactor::Attributes::Base" do
    expect(Obj).to include(Reactor::Attributes::Base)
  end
end

describe Reactor::Attributes do
  #use_vcr_cassette 'reactor'

  before do
    @crul_obj = double().as_null_object
    @obj = Obj.find_by_path('/test_obj_with_custom_attributes')
    allow(@obj).to receive(:crul_obj).and_return(@crul_obj)
  end

  shared_examples "object with settable base attributes" do
    let(:obj) { subject }

    describe "#name=" do
      it "sets name" do
        obj.name = "new_obj_name"
        expect(obj.name).to eq("new_obj_name")
      end

      it "propagates the value to [:name]" do
        obj.name = "new_obj_name"
        expect(obj[:name]).to eq("new_obj_name")
      end
    end

    describe "#channels=" do
      it "sets channels" do
        obj.channels = ["my.simple.channel"]
        expect(obj.channels).to eq(["my.simple.channel"])
      end

      it "propagates the value to [:channels]" do
        obj.channels = ["my.simple.channel"]
        expect(obj[:channels]).to eq(["my.simple.channel"])
      end
    end

    describe "#title=" do
      it "sets title" do
        obj.title = "new title"
        expect(obj.title).to eq("new title")
      end

      it "propagates the value to [:title]" do
        obj.title = "new title"
        expect(obj[:title]).to eq("new title")
      end
    end

    describe "#obj_class=" do
      it "sets obj class" do
        obj.obj_class = "OtherObjClass"
        expect(obj.obj_class).to eq("OtherObjClass")
      end

      it "propagates the value to [:obj_class]" do
        obj.obj_class = "OtherObjClass"
        expect(obj[:obj_class]).to eq("OtherObjClass")
      end
    end

    describe "#path=" do
      it "should be protected" do
        expect { obj.path= '/'}.to raise_error(NoMethodError)
      end
    end

    describe '#permalink=' do
      it "sets permalink" do
        obj.permalink = 'new-permalink'
        expect(obj.permalink).to eq('new-permalink')
      end

      it "propagates the value to [:permalink]" do
        obj.permalink = 'permalink-1234$'
        expect(obj[:permalink]).to eq('permalink-1234$')
      end
    end

    describe '#valid_from=' do
      it "sets valid_from" do
        t = DateTime.parse('Wed Aug 24 11:16:46 UTC 2011')
        obj.valid_from = t
        expect(obj.valid_from).to eq(t)
      end

      it "propagates the value to [:valid_from]" do
        t = DateTime.parse('Wed Aug 24 11:16:46 UTC 2011')
        obj.valid_from = t
        expect(obj[:valid_from]).to eq(t)
      end
    end

    describe '#valid_until=' do
      it 'sets valid_until' do
        t = DateTime.parse('Wed Aug 24 11:16:46 UTC 2011')
        obj.valid_until = t
        expect(obj.valid_until).to eq(t)
      end

      it "propagates the value to [:valid_until]" do
        t = DateTime.parse('Wed Aug 24 11:16:46 UTC 2011')
        obj.valid_until = t
        expect(obj[:valid_until]).to eq(t)
      end
    end

    describe '#suppress_export=' do
      it 'sets suppress_export' do
        t = true
        obj.suppress_export = t
        expect(obj.suppress_export).to eq(t)
      end

      it "propagates the value to [:suppress_export]" do
        t = true
        obj.suppress_export = t
        expect(obj[:suppress_export]).to eq(t)
      end
    end


    describe '#set' do
      context ':name' do
        it "sets name" do
          obj.set(:name, 'new_obj_name')
          expect(obj.name).to eq('new_obj_name')
        end
        it "propagates to [:name]" do
          obj.set(:name, 'new_obj_name')
          expect(obj[:name]).to eq('new_obj_name')
        end
      end

      context ":title" do
        it "sets title" do
          obj.set(:title, 'new title')
          expect(obj.title).to eq('new title')
        end
        it "propagates to [:title]" do
          obj.set(:title, 'new title')
          expect(obj[:title]).to eq('new title')
        end
      end

      context ':obj_class' do
        it "sets obj class" do
          obj.set(:obj_class, 'OtherObjClass')
          expect(obj.obj_class).to eq('OtherObjClass')
        end
        it "propagates to [:obj_class]" do
          obj.set(:obj_class, 'OtherObjClass')
          expect(obj[:obj_class]).to eq('OtherObjClass')
        end
      end

      context ':permalink' do
        it "sets permalink" do
          obj.set(:permalink, 'permalink1234.html')
          expect(obj.permalink).to eq('permalink1234.html')
        end
        it "propagates to [:permalink]" do
          obj.set(:permalink, 'permalink1234.html')
          expect(obj[:permalink]).to eq('permalink1234.html')
        end
      end

      context ':valid_from' do
        it "sets valid from" do
          t = DateTime.parse('Wed Aug 24 11:16:46 UTC 2011')
          obj.set(:valid_from, t)
          expect(obj.valid_from).to eq(t)
        end
        it "propagates to [:valid_from]" do
          t = DateTime.parse('Wed Aug 24 11:16:46 UTC 2011')
          obj.set(:valid_from, t)
          expect(obj[:valid_from]).to eq(t)
        end
      end

      context ':valid_until' do
        it "sets valid until" do
          t = DateTime.parse('Wed Aug 24 11:16:46 UTC 2011')
          obj.set(:valid_until, t)
          expect(obj.valid_until).to eq(t)
        end
        it "propagates to [:valid_until]" do
          t = DateTime.parse('Wed Aug 24 11:16:46 UTC 2011')
          obj.set(:valid_until, t)
          expect(obj[:valid_until]).to eq(t)
        end
      end
    end
  end

  shared_examples "object with settable custom attributes" do
    let(:obj) { subject }

    describe 'test_attr_linklist=' do
      it 'has the type linklist' do
        expect(obj.send(:attribute_type, :test_attr_linklist)).to eq(:linklist)
      end

      it "sets the linklist" do
        links = ['/object_sure_to_exist', '/', 'http://google.com']
        obj.test_attr_linklist = links
        first, second, third = obj.test_attr_linklist
        expect(first.destination_object.path).to eq(links[0])
        expect(second.destination_object.path).to eq(links[1])
        expect(third.url).to eq(links[2])
      end

      it "propagates to [:test_attr_linklist]" do
        links = ['/object_sure_to_exist', '/', 'http://google.com']
        obj.test_attr_linklist = links
        first, second, third = obj[:test_attr_linklist]
        expect(first.destination_object.path).to eq(links[0])
        expect(second.destination_object.path).to eq(links[1])
        expect(third.url).to eq(links[2])
      end
    end

    describe 'test_attr_date=' do
      it "sets test_attr_date" do
        t = DateTime.parse('Wed Aug 24 11:16:46 UTC 2011')
        obj.test_attr_date = t
        expect(obj.test_attr_date).to eq(t)
      end
      it "propagates to [:test_attr_date]" do
        t = DateTime.parse('Wed Aug 24 11:16:46 UTC 2011')
        obj.test_attr_date = t
        expect(obj[:test_attr_date]).to eq(t)
      end
    end

    describe 'test_attr_html=' do
      it 'sets test_attr_html' do
        html = '<script>alert("system hacked!");</script><b>by BillGates</b>'
        obj.test_attr_html = html
        expect(obj.test_attr_html).to eq(html)
      end
      it "propagates to [:test_attr_html]" do
        html = '<script>alert("system hacked!");</script><b>by BillGates</b>'
        obj.test_attr_html = html
        expect(obj[:test_attr_html]).to eq(html)
      end
    end

    describe 'test_attr_string=' do
      it 'sets test_attr_string' do
        str = 'Gänsefüßchen oder nicht Gänsefüßchen?!'
        obj.test_attr_string = str
        expect(obj.test_attr_string).to eq(str)
      end

      it 'propagates to [:test_attr_string]' do
        str = 'Gänsefüßchen oder nicht Gänsefüßchen?!'
        obj.test_attr_string = str
        expect(obj[:test_attr_string]).to eq(str)
      end
    end

    describe 'test_attr_text=' do
      it 'sets test_attr_text' do
        str = "Gänsefüßchen oder nicht Gänsefüßchen?!\nGänsefüßchen oder nicht Gänsefüßchen?!"
        obj.test_attr_text = str
        expect(obj.test_attr_text).to eq(str)
      end

      it 'propagates to [:test_attr_text]' do
        str = "Gänsefüßchen oder nicht Gänsefüßchen?!\nGänsefüßchen oder nicht Gänsefüßchen?!"
        obj.test_attr_text = str
        expect(obj[:test_attr_text]).to eq(str)
      end
    end

    describe 'test_attr_enum=' do
      it 'sets test_attr_enum' do
        val = 'value1'
        obj.test_attr_enum = val
        expect(obj.test_attr_enum).to eq(val)
      end

      it 'propagates to [:test_attr_enum]' do
        val = 'value2'
        obj.test_attr_enum = val
        expect(obj[:test_attr_enum]).to eq(val)
      end
    end

    describe 'test_attr_multienum=' do
      it 'sets test_attr_multienum' do
        values = ['value1', 'value3']
        obj.test_attr_multienum = values
        expect(obj.test_attr_multienum).to eq(values)
      end

      it 'propagates to [:test_attr_multienum]' do
        values = ['value1', 'value3']
        obj.test_attr_multienum = values
        expect(obj[:test_attr_multienum]).to eq(values)
      end
    end

    describe "#set" do
      it "doesn't raise exception for existing attributes" do
        [:test_attr_html, :test_attr_string, :test_attr_text, :test_attr_enum].each do |a|
          expect { obj.set(a, :token.to_s) }.not_to raise_exception
        end
        [:test_attr_date].each do |a|
          expect { obj.set(a, DateTime.now) }.not_to raise_exception
        end
      end

      it "raises exception for invalid attributes" do
        expect { obj.set(:invalid_attribute_for_sure, :token.to_s) }.to raise_exception(ArgumentError)
      end

      context ":test_attr_date" do
        it "sets test_attr_date" do
          t = Time.parse('Wed Aug 24 11:16:46 UTC 2011')
          obj.set(:test_attr_date, t)
          expect(obj.test_attr_date).to eq(t)
        end
        it "propagates to [:test_attr_date]" do
          t = Time.parse('Wed Aug 24 11:16:46 UTC 2011')
          obj.set(:test_attr_date, t)
          expect(obj[:test_attr_date]).to eq(t)
        end
      end

      context ':test_attr_html' do
        it 'sets to test_attr_html' do
          html = '<script>alert("system hacked!");</script><b>by BillGates</b>'
          obj.set(:test_attr_html, html)
          expect(obj[:test_attr_html]).to eq(html)
        end
        it 'propagates to [:test_attr_html]' do
          html = '<script>alert("system hacked!");</script><b>by BillGates</b>'
          obj.set(:test_attr_html, html)
          expect(obj[:test_attr_html]).to eq(html)
        end
      end

      context ':test_attr_string' do
        it 'sets test_attr_string' do
          str = 'Gänsefüßchen oder nicht Gänsefüßchen?!'
          obj.set(:test_attr_string, str)
          expect(obj.test_attr_string).to eq(str)
        end

        it 'propagates to [:test_attr_string]' do
          str = 'Gänsefüßchen oder nicht Gänsefüßchen?!'
          obj.set(:test_attr_string, str)
          expect(obj[:test_attr_string]).to eq(str)
        end
      end

      context ':test_attr_text' do
        it 'sets test_attr_text' do
          str = "Gänsefüßchen oder nicht Gänsefüßchen?!\nGänsefüßchen oder nicht Gänsefüßchen?!"
          obj.set(:test_attr_text, str)
          expect(obj.test_attr_text).to eq(str)
        end

        it 'propagates to [:test_attr_text]' do
          str = "Gänsefüßchen oder nicht Gänsefüßchen?!\nGänsefüßchen oder nicht Gänsefüßchen?!"
          obj.set(:test_attr_text, str)
          expect(obj[:test_attr_text]).to eq(str)
        end
      end

      context ':test_attr_enum' do
        it 'sets test_attr_enum' do
          val = 'value1'
          obj.set(:test_attr_enum, val)
          expect(obj.test_attr_enum).to eq(val)
        end

        it 'propagates to [:test_attr_enum]' do
          val = 'value2'
          obj.set(:test_attr_enum, val)
          expect(obj[:test_attr_enum]).to eq(val)
        end
      end

      context ':test_attr_multienum' do
        it 'sets test_attr_multienum' do
          values = ['value1', 'value3']
          obj.set(:test_attr_multienum, values)
          expect(obj.test_attr_multienum).to eq(values)
        end

        it 'propagates to [:test_attr_multienum]' do
          values = ['value1', 'value3']
          obj.set(:test_attr_multienum, values)
          expect(obj[:test_attr_multienum]).to eq(values)
        end
      end
    end
  end

  shared_examples 'object with indifferent body and blob' do
    let(:obj) {subject}

    it 'sets body and blob (read using method calls)' do
      val = 'new body value'
      obj.body = val
      expect(obj.blob).to eq(val)
    end

    it 'sets body and blob (read using [] method)' do
      val = 'new body value'
      obj.body = val
      expect(obj[:blob]).to eq(val)
    end

    it 'sets blob and body (read using method calls)' do
      val = 'new body value'
      obj.blob = val
      expect(obj.body).to eq(val)
    end

    it 'sets blob and body (read using [] method)' do
      val = 'new body value'
      obj.blob = val
      expect(obj[:body]).to eq(val)
    end

    describe '#set' do
      it 'sets body and blob (read using method calls)' do
        val = 'new body value'
        obj.set(:body, val)
        expect(obj.blob).to eq(val)
      end

      it 'sets body and blob (read using [] method)' do
        val = 'new body value'
        obj.set(:body, val)
        expect(obj[:blob]).to eq(val)
      end

      it 'sets blob and body (read using method calls)' do
        val = 'new body value'
        obj.set(:blob, val)
        expect(obj.body).to eq(val)
      end

      it 'sets blob and body (read using [] method)' do
        val = 'new body value'
        obj.set(:blob, val)
        expect(obj[:body]).to eq(val)
      end
    end
  end

  shared_examples "date attribute" do |obj, attr|
    # TODO: this behaviour happens ONLY after reload
    #
    # it "sets time as utc" do
    #   t = Time.parse("Wed Sep 07 11:54:32 +0200 2011")
    #   obj.send("#{attr}=", t)
    #   obj.send("#{attr}").should be_utc
    # end
    #
    # it "strips usec" do
    #   t = Time.parse("Wed Sep 07 11:54:32.123 +0200 2011")
    #   obj.send("#{attr}=", t)
    #   obj.send("#{attr}").usec.should == 0
    # end
  end

  shared_examples "link serializing attribute" do |obj, attr|
    before do
      @target_path = '/my/path/abc'
      @target_name = 'abc'
      @target_id = 12345
      @target_obj = stub_obj(Obj, :path => @target_path)
      allow(Obj).to receive(:find) do |id|
        @target_obj if id == @target_id
      end
    end

    it "rewrites links with matching path and existing obj" do
      allow(Obj).to receive(:exists?) {|id| id == @target_id}

      obj.set(attr, "<a href=\"/#{@target_id}/#{@target_name}\">link</a>")
      expect(obj.send(attr)).to eq("<a href=\"#{@target_path}\">link</a>")
    end

    context "for objects with permalink" do
      before do
        @obj_w_permalink_path = '/my/path/abc'
        @obj_w_permalink_permalink = 'permalink'
        @obj_w_permalink = stub_obj(Obj, :path => @obj_w_permalink_path, :permalink => @obj_w_permalink_permalink)
        allow(Obj).to receive(:find_by_permalink) do |permalink|
          @obj_w_permalink if permalink == @obj_w_permalink_permalink
        end
      end

      it "rewrites links with matching permalink and existing obj" do
        allow(Obj).to receive(:exists?) {|options| options[:permalink] == @obj_w_permalink_permalink}
        obj.set(attr, "<a href=\"/#{@obj_w_permalink_permalink}\">link</a>")
        expect(obj.send(attr)).to eq("<a href=\"#{@obj_w_permalink_path}\">link</a>")
      end

      context "when running under a relative root" do
        before do
          ENV['RAILS_RELATIVE_URL_ROOT'] = '/mpi'
        end

        it "rewrites links with matching permalink and existing obj" do
          allow(Obj).to receive(:exists?) {|options| options[:permalink] == @obj_w_permalink_permalink}
          obj.set(attr, "<a href=\"/mpi/#{@obj_w_permalink_permalink}\">link</a>")
          expect(obj.send(attr)).to eq("<a href=\"#{@obj_w_permalink_path}\">link</a>")
        end
      end
    end

    context "when running under a relative root" do
      before do
        ENV['RAILS_RELATIVE_URL_ROOT'] = '/mpi'
      end

      it "rewrites links with matching path and existing obj" do
        allow(Obj).to receive(:exists?) {|id| id == @target_id}
        obj.set(attr, "<a href=\"/mpi/#{@target_id}/#{@target_name}\">link</a>")
        expect(obj.send(attr)).to eq("<a href=\"#{@target_path}\">link</a>")
      end
    end

    it "doesn't rewrite links without matching path" do
      obj.set(attr, "<a href=\"/unmatching/123/file\">link</a>")
      expect(obj.send(attr)).to eq("<a href=\"/unmatching/123/file\">link</a>")
    end

    it "doesn't rewrite links with matching path but without matching obj" do
      allow(Obj).to receive(:exists?) {|id| !(id == 6743)}
      obj.set(attr, "<a href=\"/6743/matching_no_obj\">link</a>")
      expect(obj.send(attr)).to eq("<a href=\"/6743/matching_no_obj\">link</a>")
    end

    it "doesn't rewrite external links" do
      obj.set(attr, "<a href=\"http://localhost:3100/#{@target_id}/#{@target_path}\">link</a>")
      expect(obj.send(attr)).to eq("<a href=\"http://localhost:3100/#{@target_id}/#{@target_path}\">link</a>")
    end
  end

  context "plain new Obj instance" do
    subject { Obj.new }
    it_behaves_like "object with settable base attributes"
    it_behaves_like "object with indifferent body and blob"
  end

  context "instance of Obj with custom attributes" do
    subject { Obj.find_by_path('/test_obj_with_custom_attributes') }
    it_behaves_like "object with settable base attributes"
    it_behaves_like "object with indifferent body and blob"

    context "after attribute reload" do
      subject { x = Obj.find_by_path('/test_obj_with_custom_attributes') ; x.send(:reload_attributes) ; x }
      it_behaves_like "object with settable custom attributes"
    end
  end

  context "instance of subclass of Obj with custom attributes" do
    # class TestClassWithCustomAttributes < Obj
    # end

    subject {TestClassWithCustomAttributes.find_by_path('/test_obj_with_custom_attributes')}

    it_behaves_like "object with settable base attributes"
    it_behaves_like "object with settable custom attributes"
    it_behaves_like "object with indifferent body and blob"
  end

  describe "valid_from (builtin date attribute)" do
    obj = Obj.new
    it_behaves_like "date attribute", obj, :valid_from
  end

  describe "valid_until (builtin date attribute)" do
    obj = Obj.new
    it_behaves_like "date attribute", obj, :valid_until
  end

  describe "test_attr_date (custom date attribute)" do
    obj = TestClassWithCustomAttributes.find_by_path('/test_obj_with_custom_attributes')
    it_behaves_like "date attribute", obj, :test_attr_date
  end

  describe "body" do
    it_behaves_like "link serializing attribute", Obj.new, :body
  end

  describe "test_attr_html" do
    it_behaves_like "link serializing attribute", TestClassWithCustomAttributes.find_by_path('/test_obj_with_custom_attributes'), :body
  end

  describe "test_attr_string" do
    let(:obj)  { TestClassWithCustomAttributes.find_by_path('/test_obj_with_custom_attributes') }
    let(:attr) { :test_attr_string }
    before do
      @target_path = '/my/path/abc'
      @target_name = 'abc'
      @target_id = 12345
      @target_obj = stub_obj(Obj, :path => @target_path)
      allow(Obj).to receive_message_chain(:select, :find) {|id| @target_obj if id == @target_id }
    end

    it "isn't a link serializing attribute" do
      allow(Obj).to receive(:exists?) {|id| id == @target_id}

      obj.set(attr, "<a href=\"/#{@target_id}/#{@target_name}\">link</a>")
      expect(obj.send(attr)).to eq("<a href=\"/#{@target_id}/#{@target_name}\">link</a>")
    end
  end
end
