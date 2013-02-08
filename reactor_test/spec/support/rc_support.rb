# -*- encoding : utf-8 -*-
module RCSupport
  def stub_obj(class_name, attributes={})
    stub = stub_model(class_name)
    stub.stub(:[]) do |passed_attr|
      attributes[passed_attr]
    end
    attributes.each do |key, value|
      stub.stub(key.to_sym) { value }
    end
    stub
  end
end
