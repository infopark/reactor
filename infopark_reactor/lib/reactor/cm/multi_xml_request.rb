require "net/http"
require "reactor/cm/xml_response"
require "reactor/cm/xml_multi_request_error"
require "reactor/cm/xml_markup"
require "nokogiri"

module Reactor
  module Cm
    class MultiXmlRequest
      def self.timeout
        Reactor::Cm::XmlRequest.timeout
      end

      def self.token(login, instance_secret)
        Digest::MD5.hexdigest(login + instance_secret)
      end

      def self.execute
        access = Configuration.xml_access
        sanity_check(access)
        xml = XmlMarkup.new
        xml.instruct!
        req = nil
        ret = xml.tag!("cm-payload", "payload-id" => "abcabc", "timestamp" => Time.now.getutc.strftime("%Y%m%d%H%M%S"), "version" => "6.7.3") do
          xml.tag!("cm-header") do
            xml.tag!("cm-sender", "sender-id" => access[:id], "name" => "ruby-simple-client")
            xml.tag!("cm-authentication", "login" => access[:username], "token" => token(access[:username], access[:secret]))
          end
          req = new(xml).tap do |instance|
            yield instance
          end
        end
        req.execute!(ret)
      end

      def mandatory
        req_id = self.class.generate_id
        @mandatory << req_id
        @builder.tag!("cm-request", "request-id" => req_id, "preclusive" => "true") do |xml2|
          yield xml2
        end
      end

      def optional
        req_id = self.class.generate_id
        @optional << req_id
        @builder.tag!("cm-request", "request-id" => req_id, "preclusive" => "false") do |xml2|
          yield xml2
        end
      end

      def execute!(xml)
        access = Configuration.xml_access
        payload = xml

        res = Net::HTTP.new(access[:host], access[:port]).start do |http|
          http.read_timeout = self.class.timeout
          req = Net::HTTP::Post.new("/xml")
          req.body = payload
          http.request(req)
        end

        MultiXmlResponse.new(res.body, @mandatory, @optional)
      end

      class << self
        def generate_id
          rand(10_000)
        end

        protected

        def sanity_check(access)
          raise Reactor::Cm::MissingCredentials if access[:username].nil? || access[:username].empty?
        end
      end

      protected

      def initialize(builder)
        @builder = builder
        @mandatory = []
        @optional = []
      end

      class MultiXmlResponse
        def initialize(xml, mandatory, optional)
          @xml = xml
          @mandatory = mandatory
          @optional = optional
          @n = Nokogiri::XML.parse(@xml)
        end

        def assert_success
          first_failed = nil
          @mandatory.any? do |mandatory_id|
            @n.xpath("//cm-response[@request-id='#{mandatory_id}']//cm-code[@numeric='200']").empty? && (first_failed = mandatory_id)
          end && raise(XmlMultiRequestError, @n.xpath("//cm-response[@request-id='#{first_failed}']//cm-code//error/phrase/text()").map(&:to_s).join("\n"))
        end
      end
    end
  end
end
