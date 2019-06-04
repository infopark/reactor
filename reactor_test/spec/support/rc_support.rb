# frozen_string_literal: true

module RCSupport
  def stub_obj(class_name, attributes={})
    stub = stub_model(class_name)
    allow(stub).to receive(:[]) do |passed_attr|
      attributes[passed_attr]
    end
    attributes.each do |key, value|
      allow(stub).to receive(key.to_sym) { value }
    end
    stub
  end
end
