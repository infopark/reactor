require 'spec_helper'
require 'digest/md5'

shared_examples "txt uploadable object" do
  context "for allowed file extension" do
    context "given File.open object" do
      before do
        # Tempfile will not work!
        @data = "my file\ncöntents!!\r\naa\rxx"
        @path = "/tmp/uploadable#{Time.now.strftime("%Y%m%d")}-#{rand(0x100000000)}"
        @file = File.open(@path, File::RDWR|File::TRUNC|File::CREAT)
        @file.write(@data)
        @file.rewind
      end

      after do
        @file.close
        File.unlink(@path)
      end

      it "uploads the file contents" do
        @obj.upload(@file, 'txt')
        @obj.save!
        @obj.body.should == @data
      end
    end

    context "given a string" do
      before { @data = "my file\ncöntents!!\r\naa\rxx" }
      it "uploads its contents" do
        @obj.upload(@data, 'txt')
        @obj.save!
        @obj.body.should == @data
      end
    end
  end

  context "for disallowed file extension" do
    it "raises an exception" do
      @obj.upload('Hai', 'xxx')
      expect {@obj.save!}.to raise_exception
    end
  end
end

shared_examples "jpg uploadable object" do
  context "for allowed file extension" do
    context "given an jpg image" do
      before do
        @file_path = ::File.join(Rails.root, 'spec', 'fixtures', '53b01fb15ffe3a9e83675a3c80d639c6.jpg')
        @file_ext = ::File.extname(@file_path)[1..-1]
        @file = ::File.open(@file_path)
      end
      after do
        @file.close
      end

      it "uploads the image" do
        md5_before = Digest::MD5.file(@file_path).hexdigest
        @obj.upload(@file, @file_ext)
        @obj.save!
        @obj.reload
        md5_after = Digest::MD5.hexdigest(@obj.body)
        md5_before.should eq(md5_after)
      end

      it "persists the image" do
        md5_before = Digest::MD5.file(@file_path).hexdigest
        @obj.upload(@file, @file_ext)
        @obj.save!
        @obj = @obj.class.find(@obj.obj_id)
        md5_after = Digest::MD5.hexdigest(@obj.body)
        md5_before.should eq(md5_after)
      end
    end

    context "given a string" do
      before { @data = ::File.read(::File.join(Rails.root, 'spec', 'fixtures', '53b01fb15ffe3a9e83675a3c80d639c6.jpg')) }
      it "uploads its contents" do
        @obj.upload(@data, 'jpg')
        @obj.save!
        Digest::MD5.hexdigest(@obj.body).should == Digest::MD5.hexdigest(@data)
      end
    end
  end

  context "for disallowed file extension" do
    it "raises an exception" do
      @obj.upload('Hai', 'xxx')
      expect {@obj.save!}.to raise_exception
    end
  end
end

shared_examples "binary uploadable object" do
  context "for allowed file extension" do
    context "given a binary file" do
      before do
        @file_path = ::File.join(Rails.root, 'spec', 'fixtures', @file_name)
        @file_ext = ::File.extname(@file_path)[1..-1]
        @file = ::File.open(@file_path)
      end
      after do
        @file.close
      end

      it "uploads the file" do
        md5_before = Digest::MD5.file(@file_path).hexdigest
        @obj.upload(@file, @file_ext)
        @obj.save!
        @obj.reload
        md5_after = Digest::MD5.hexdigest(@obj.body)
        md5_before.should eq(md5_after)
      end

      it "persists the file" do
        md5_before = Digest::MD5.file(@file_path).hexdigest
        @obj.upload(@file, @file_ext)
        @obj.save!
        @obj = @obj.class.find(@obj.obj_id)
        md5_after = Digest::MD5.hexdigest(@obj.body)
        md5_before.should eq(md5_after)
      end
    end

    context "given a string" do
      before { @data = ::File.read(::File.join(Rails.root, 'spec', 'fixtures', @file_name)) }
      it "uploads its contents" do
        @obj.upload(@data, ::File.extname(@file_name)[1..-1])
        @obj.save!
        @obj.reload
        Digest::MD5.hexdigest(@obj.body).should == Digest::MD5.hexdigest(@data)
      end
    end
  end

  context "for disallowed file extension" do
    it "raises an exception" do
      @obj.upload('Hai', 'xxx')
      expect {@obj.save!}.to raise_exception
    end
  end
end

describe "Brand new obj instance" do
  pending
  # it_behaves_like "uploadable object" do
  #   before {@obj = Obj.new(:name => 'uploadable_test', :parent => '/', :obj_class => 'PlainObjClass') }
  #   after { @obj.destroy }
  # end
end

describe "Created txt-compatible obj" do
  it_behaves_like "txt uploadable object" do
    before {@obj = Obj.create(:name => 'uploadable_test', :parent => '/', :obj_class => 'PlainObjClass')}
    after { @obj.destroy }
  end
end

describe "Existing txt-compatible obj" do
  it_behaves_like "txt uploadable object" do
    before {@obj = Obj.create(:name => 'uploadable_test', :parent => '/', :obj_class => 'PlainObjClass') ; @obj = Obj.find(@obj.id) }
    after { @obj.destroy }
  end
end

describe "Created jpg-compatible obj" do
  it_behaves_like "jpg uploadable object" do
    before {@obj = Obj.create(:name => 'uploadable_test', :parent => '/', :obj_class => 'Image')}
    after { @obj.destroy }
  end
end

describe "Created zip-compatible obj" do
  it_behaves_like "binary uploadable object" do
    before {@file_name = 'zero.zip'}
    before {@obj = Obj.create(:name => 'uploadable_test', :parent => '/', :obj_class => 'Generic')}
    after { @obj.destroy }
  end
end

describe "Existing zip-compatible obj" do
  it_behaves_like "binary uploadable object" do
    before {@file_name = 'zero.zip'}
    before {@obj = Obj.create(:name => 'uploadable_test', :parent => '/', :obj_class => 'Generic') ; @obj = Obj.find(@obj.id) }
    after { @obj.destroy }
  end
end

describe "Existing jpg-compatible obj" do
  it_behaves_like "jpg uploadable object" do
    before {@obj = Obj.create(:name => 'uploadable_test', :parent => '/', :obj_class => 'Image') ; @obj = Obj.find(@obj.id) }
    after { @obj.destroy }
  end
end

describe "Created compatible obj [FAKE]" do
  it_behaves_like "binary uploadable object" do
    before {@file_name = 'fake.zip'}
    before {@obj = Obj.create(:name => 'uploadable_test', :parent => '/', :obj_class => 'Generic')}
    after { @obj.destroy }
  end
end

describe "Existing compatible obj [FAKE]" do
  it_behaves_like "binary uploadable object" do
    before {@file_name = 'fake.zip'}
    before {@obj = Obj.create(:name => 'uploadable_test', :parent => '/', :obj_class => 'Generic') ; @obj = Obj.find(@obj.id) }
    after { @obj.destroy }
  end
end

describe "Created pdf-compatible obj" do
  it_behaves_like "binary uploadable object" do
    before {@file_name = '5a2d761cab7c15b2b3bb3465ce64586d.pdf'}
    before {@obj = Obj.create(:name => 'uploadable_test', :parent => '/', :obj_class => 'Generic')}
    after { @obj.destroy }
  end
end

describe "Existing pdf-compatible obj" do
  it_behaves_like "binary uploadable object" do
    before {@file_name = '5a2d761cab7c15b2b3bb3465ce64586d.pdf'}
    before {@obj = Obj.create(:name => 'uploadable_test', :parent => '/', :obj_class => 'Generic') ; @obj = Obj.find(@obj.id) }
    after { @obj.destroy }
  end
end

describe '.upload' do
  before do
    @file_name = '5a2d761cab7c15b2b3bb3465ce64586d.pdf'
    @file_path = ::File.join(Rails.root, 'spec', 'fixtures', @file_name)
    @file_ext = ::File.extname(@file_path)[1..-1]
    @file = ::File.open(@file_path)
  end

  after do
    @file.close
  end

  it "uploads the file" do
    md5_before = Digest::MD5.file(@file_path).hexdigest
    obj = Obj.upload(@file, @file_ext, :name => 'uploadable_test', :parent => '/', :obj_class => 'Generic')
    md5_after = Digest::MD5.hexdigest(obj.body)
    obj.destroy
    md5_before.should eq(md5_after)
  end

  it "guesses the filename" do
    obj = Obj.upload(@file, @file_ext, :parent => '/', :obj_class => 'Generic')
    name = obj.name
    obj.destroy

    name.should eq(::File.basename(@file_name, ::File.extname(@file_name)))
  end
end