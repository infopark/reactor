require 'benchmark'

container = Obj.create(:name => 'benchmark_container', :parent => '/', :obj_class => 'publication')

xml_blob = <<-EOXML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE TestClassWithCustomAttributes SYSTEM "TestClassWithCustomAttributes.dtd">
<TestClassWithCustomAttributes xmlns:default="http://www.w3.org/TR/REC-html40">
  <test_attr_linklist>
    <freeLink>
      <destinationUrl>http://google.com</destinationUrl>
    </freeLink>
    <freeLink>
      <destinationUrl>http://microsoft.com</destinationUrl>
    </freeLink>
    <freeLink>
      <destinationUrl>http://abc.com</destinationUrl>
    </freeLink>
  </test_attr_linklist>
  <test_attr_date>20111011130000</test_attr_date>
  <test_attr_html>&lt;strong&gt;html&lt;/strong&gt;</test_attr_html>
  <test_attr_string>string</test_attr_string>
  <test_attr_text>text</test_attr_text>
  <test_attr_enum>value1</test_attr_enum>
  <test_attr_multienum>value2</test_attr_multienum>
  <test_attr_multienum>value3</test_attr_multienum>
  <default:body>test, test, 123</default:body>
</TestClassWithCustomAttributes>
EOXML

Benchmark.bm(30) do |x|
  x.report("raw request (lower bound)") do
    100.times do
      Reactor::Cm::XmlRequest.prepare do |xml|
        xml.tag!('obj-where') { xml.tag!('id', container.id) }
        xml.tag!('obj-create') do
          xml.tag!('name', 'from_xml')
          xml.tag!('objClass', 'TestClassWithCustomAttributes')
        end
      end.execute!
    end
  end
  x.report("without setting attributes") do
    100.times do
      TestClassWithCustomAttributes.create(:name => 'without_setting_attributes', :parent => container)
    end
  end
  x.report("raw request (all attributes)") do
    100.times do
      Reactor::Cm::XmlRequest.prepare do |xml|
        xml.tag!('obj-where') { xml.tag!('id', container.id) }
        xml.tag!('obj-create') do
          xml.tag!('name', 'from_xml')
          xml.tag!('xmlBlob', xml_blob)
        end
      end.execute!
    end
  end
  x.report("setting all custom attributes") do
    100.times do
      #["test_attr_linklist", "test_attr_text", "test_attr_html", "test_attr_date", "test_attr_enum", "test_attr_string", "test_attr_multienum"]
      TestClassWithCustomAttributes.create(:name => 'settin_all_custom_attributes', :parent => container,
                                           :test_attr_linklist => ['http://google.com', 'http://microsoft.com', '/'],
                                           :test_attr_text => 'einfacher text',
                                           :test_attr_string => 'einfacher string',
                                           :test_attr_html => 'das ist <b>HTML</b>',
                                           :test_attr_enum => 'value1',
                                           :test_attr_multienum => ['value1', 'value2'],
                                           :test_attr_date => Time.now)

    end
  end
end

container.children.each(&:destroy)
container.destroy
