# -*- encoding : utf-8 -*-
require 'net/http'
require 'reactor/cm/xml_response'
require 'reactor/cm/xml_single_request_error'
require 'reactor/cm/xml_markup'
require 'reactor/tools/smart_xml_logger'

module Reactor
  module Cm

    if Rails.env.development? && false
      #LOGGER = SmartXmlLogger.new(Rails.logger, :debug)
      LOGGER = SmartXmlLogger.new(Kernel, :puts)
    else
      LOGGER = SmartXmlLogger.new(nil)   # turn off logging
    end
    LOGGER.configure(:request, :xpath => 'cm-payload/cm-request/*', :start_indent => 2)
    LOGGER.configure(:response, :xpath => 'cm-payload/cm-response/*', :start_indent => 2)

    class XmlRequest
      cattr_accessor :timeout
      self.timeout = 60

      def self.token(login, instance_secret)
        Digest::MD5.hexdigest(login + instance_secret)
      end

      def self.prepare
        access = Configuration::xml_access
        sanity_check(access)
        xml = XmlMarkup.new
        ret = nil
        xml.instruct!
        ret = xml.tag!('cm-payload', 'payload-id' =>'abcabc', 'timestamp' => Time.now.getutc.strftime('%Y%m%d%H%M%S'), 'version' => '6.7.3') do
          xml.tag!('cm-header') do
            xml.tag!('cm-sender', 'sender-id' => access[:id], 'name' => "ruby-simple-client")
            xml.tag!('cm-authentication', 'login' => access[:username], 'token' => token(access[:username],access[:secret]))
          end
          id = self.generate_id
          xml.tag!('cm-request', 'request-id' => id) do |xml2|
            yield xml2 if block_given?
          end
        end
        XmlRequest.new(ret)
      end

      def execute!
        access = Configuration::xml_access
        payload = @xml

        res = Net::HTTP.new(access[:host], access[:port]).start do |http|
          http.read_timeout = self.class.timeout
          req = Net::HTTP::Post.new('/xml')
          Reactor::Cm::LOGGER.log('REQUEST:')
          Reactor::Cm::LOGGER.log_xml(:request, payload)
          req.body = payload
          http.request(req)
        end
        Reactor::Cm::LOGGER.log('RESPONSE:')
        Reactor::Cm::LOGGER.log_xml(:response, res.body)
        response = XmlResponse.new(res.body)
        raise XmlSingleRequestError, response unless response.ok?
        response
      end

      class << self
        protected

        def generate_id
          rand(10000)
        end

        def sanity_check(access)
          raise Reactor::Cm::MissingCredentials if access[:username].nil? || access[:username].empty?
        end
      end

      protected

      def initialize(xml)
        @xml = xml
      end

    end
  end
end
