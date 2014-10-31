# -*- encoding : utf-8 -*-
require 'spec_helper'

unless defined?(TestClassWithCustomAttributes)
  class TestClassWithCustomAttributes < Obj
  end
end

describe "in-content link persisting" do
  # FIXME: somehow all requests are stored and never reused
  #use_vcr_cassette "link_persisting"

  shared_examples "persistent link serializer" do
    before :all do
      @sure_object = Obj.find_by_path('/object_sure_to_exist')
      @sure_image = Obj.find_by_path('/image_sure_to_exist')
      @sure_object.update_attributes!(permalink: 'object_sure_to_exist') if @sure_object.permalink != 'object_sure_to_exist'
      @sure_image.update_attributes!(permalink: 'image_sure_to_exist') if @sure_image.permalink != 'image_sure_to_exist'

      @sure_object2 = Obj.create!(:obj_class => 'PlainObjClass', :name => 'object_sure_to_exist2', :parent => '/')
      @sure_image2 = Obj.create!(:obj_class => 'image', :name => 'image_sure_to_exist2', :parent => '/')
    end
    after :all do
      @sure_object2.destroy
      @sure_image2.destroy
    end

    context "given a link to existing obj" do
      context "with paths" do
        it "stores an internal link" do
          obj.send(:"#{attr}=", %Q|<a href="/object_sure_to_exist2">link</a> text|)
          obj.save!
          obj.text_links.first.destination_object.path.should eq('/object_sure_to_exist2')
          Obj.find(obj.id).send(attr).should match(/internallink:/)
        end


        context "from html-safe string" do
          it "stores an internal link" do
            obj.send(:"#{attr}=", %Q|<a href="/object_sure_to_exist2">link</a> text|.html_safe)
            obj.save!
            obj.text_links.first.destination_object.path.should eq('/object_sure_to_exist2')
            Obj.find(obj.id).send(attr).should match(/internallink:/)
          end
        end

        context "given fully qualified url as image source" do
          it "stores the url" do
            obj.send(:"#{attr}=", %Q|<img src="http://www.page.com/object_sure_to_exist2"> text|.html_safe)
            obj.save!
            obj.text_links.first.url.should eq('http://www.page.com/object_sure_to_exist2')
          end
        end

        context "given fully qualified url" do
          it "stores the url" do
            obj.send(:"#{attr}=", %Q|<a href="http://www.page.com/object_sure_to_exist2">link</a> text|.html_safe)
            obj.save!
            obj.text_links.first.url.should eq('http://www.page.com/object_sure_to_exist2')
          end
        end

        context "given an image tag with existing obj as source" do
          it "stores an internal link" do
            obj.send(:"#{attr}=", %Q|<img src="/image_sure_to_exist2">|)
            obj.save!
            obj.text_links.first.destination_object.path.should eq('/image_sure_to_exist2')
            Obj.find(obj.id).send(attr).should match(/internallink:/)
          end
        end

        context "given a HTML5 image tag with existing obj as source" do
          it "stores an internal link" do
            obj.send(:"#{attr}=", %Q|<img src="/image_sure_to_exist2" />|)
            obj.save!
            obj.text_links.first.destination_object.path.should eq('/image_sure_to_exist2')
            Obj.find(obj.id).send(attr).should match(/internallink:/)
          end
        end
      end

      context "with permalinks" do
        it "stores an internal link" do
          obj.send(:"#{attr}=", %Q|<a href="/object_sure_to_exist">link</a> text|)
          obj.save!
          obj.text_links.first.destination_object.permalink.should eq('object_sure_to_exist')
          Obj.find(obj.id).send(attr).should match(/internallink:/)
        end


        context "from html-safe string" do
          it "stores an internal link" do
            obj.send(:"#{attr}=", %Q|<a href="/object_sure_to_exist">link</a> text|.html_safe)
            obj.save!
            obj.text_links.first.destination_object.permalink.should eq('object_sure_to_exist')
            Obj.find(obj.id).send(attr).should match(/internallink:/)
          end
        end

        context "given fully qualified url as image source" do
          it "stores the url" do
            obj.send(:"#{attr}=", %Q|<img src="http://www.page.com/object_sure_to_exist"> text|.html_safe)
            obj.save!
            obj.text_links.first.url.should eq('http://www.page.com/object_sure_to_exist')
          end
        end

        context "given fully qualified url" do
          it "stores the url" do
            obj.send(:"#{attr}=", %Q|<a href="http://www.page.com/object_sure_to_exist">link</a> text|.html_safe)
            obj.save!
            obj.text_links.first.url.should eq('http://www.page.com/object_sure_to_exist')
          end
        end
      end

      context "given an image tag with existing obj as source" do
        it "stores an internal link" do
          obj.send(:"#{attr}=", %Q|<img src="/image_sure_to_exist">|)
          obj.save!
          obj.text_links.first.destination_object.permalink.should eq('image_sure_to_exist')
          Obj.find(obj.id).send(attr).should match(/internallink:/)
        end
      end

      context "given a HTML5 image tag with existing obj as source" do
        it "stores an internal link" do
          obj.send(:"#{attr}=", %Q|<img src="/image_sure_to_exist" />|)
          obj.save!
          obj.text_links.first.destination_object.permalink.should eq('image_sure_to_exist')
          Obj.find(obj.id).send(attr).should match(/internallink:/)
        end
      end

      context "with /:id/:name" do
        before do
          @idname = "/#{@sure_object.id}/#{@sure_object.name}"
          @objid = @sure_object.id
        end

        it "stores an internal link" do
          obj.send(:"#{attr}=", %Q|<a href="#{@idname}">link</a> text|)
          obj.save!
          obj.text_links.first.destination_object.permalink.should eq('object_sure_to_exist')
          Obj.find(obj.id).send(attr).should match(/internallink:/)
        end

        context "from html-safe string" do
          it "stores an internal link" do
            obj.send(:"#{attr}=", %Q|<a href="#{@idname}">link</a> text|.html_safe)
            obj.save!
            obj.text_links.first.destination_object.permalink.should eq('object_sure_to_exist')
            Obj.find(obj.id).send(attr).should match(/internallink:/)
          end
        end

        context "given fully qualified url as image source" do
          it "stores the url" do
            obj.send(:"#{attr}=", %Q|<img src="http://www.page.com#{@idname}"> text|.html_safe)
            obj.save!
            obj.text_links.first.url.should eq("http://www.page.com#{@idname}")
          end
        end

        context "given fully qualified url" do
          it "stores the url" do
            obj.send(:"#{attr}=", %Q|<a href="http://www.page.com#{@idname}">link</a> text|.html_safe)
            obj.save!
            obj.text_links.first.url.should eq("http://www.page.com#{@idname}")
          end
        end
      end
    end

    context "given a malformed HTML5 image tag with existing obj as source" do
      it "stores an internal link" do
        obj.send(:"#{attr}=", %Q|<img src="/image_sure_to_exist"/>|)
        obj.save!
        Obj.find(obj.id).send(attr).should match(/internallink:/)
        obj.text_links.should_not be_empty
      end
    end

    context "given a link to nonexistent obj" do
      it "stores an link" do
        obj.send(:"#{attr}=", %Q|<a href="/nonexistent_object">link</a> text|)
        obj.save!
        Obj.find(obj.id).send(attr).should match(/internallink:/)
        obj.text_links.should be_empty
      end
    end

    context "given an image tag with nonexistent obj as source" do
      it "stores an internal link" do
        obj.send(:"#{attr}=", %Q|<img src="/nonexistent_object">|)
        obj.save!
        Obj.find(obj.id).send(attr).should match(/internallink:/)
        obj.text_links.should be_empty
      end
    end

    context "given an external link" do
      it "stores an external link" do
        obj.send(:"#{attr}=", %Q|<a href="http://google.com">link</a> text|)
        obj.save!
        Obj.find(obj.id).send(attr).should match(/internallink:/) # YES! It stores external links with internallink: :-)
        obj.text_links.should_not be_empty
      end
    end
  end

  shared_examples "no link serialization" do
    it "doesn't write any internal links" do
      obj.send(:"#{attr}=", %Q|<a href="/object_sure_to_exist">link</a> text|)
      obj.save!
      obj.resolve_refs! # just to be extra sure, force resolve refs
      Obj.find(obj.id).send(attr).should == %Q|<a href="/object_sure_to_exist">link</a> text|
    end

    it "doesn't write any external links" do
      obj.send(:"#{attr}=", %Q|<a href="http://google.com">link</a> text|)
      obj.save!
      obj.resolve_refs! # just to be extra sure, force resolve refs
      Obj.find(obj.id).send(attr).should == %Q|<a href="http://google.com">link</a> text|
    end
  end

  describe "storing links in Obj body" do
    it_behaves_like "persistent link serializer" do
      let(:obj) { Obj.create(:name => 'link_serializer', :parent => '/', :obj_class => 'PlainObjClass')}
      let(:attr) { :body }
      after { obj.destroy }
    end
  end

  describe "storing links in TestClassWithCustomAttributes body" do
    it_behaves_like "persistent link serializer" do
      let(:obj) { TestClassWithCustomAttributes.create(:name => 'link_serializer', :parent => '/')}
      let(:attr) { :body }
      after { obj.destroy }
    end
  end

  describe "storing links in TestClassWithCustomAttributes test_attr_html" do
    it_behaves_like "persistent link serializer" do
      let(:obj) { TestClassWithCustomAttributes.create(:name => 'link_serializer', :parent => '/')}
      let(:attr) { :test_attr_html }
      after { obj.destroy }
    end
  end

  describe "storing links in TestClassWithCustomAttributes test_attr_string" do
    it_behaves_like "no link serialization" do
      let(:obj) { TestClassWithCustomAttributes.create(:name => 'link_serializer', :parent => '/')}
      let(:attr) { :test_attr_string }
      after { obj.destroy }
    end
  end

  describe "storing links in TestClassWithCustomAttributes test_attr_text" do
    it_behaves_like "no link serialization" do
      let(:obj) { TestClassWithCustomAttributes.create(:name => 'link_serializer', :parent => '/')}
      let(:attr) { :test_attr_text }
      after { obj.destroy }
    end
  end
end
