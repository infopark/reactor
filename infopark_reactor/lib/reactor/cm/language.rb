module Reactor
  module Cm
    class Language
      def self.get(username = nil)
        begin
          options = {}
          options = { login: username } if username
          request = XmlRequest.prepare do |xml|
            xml.tag!("userConfig-getTexts", options) do
              xml.tag!("listitem") do
                xml.text!("languages.language")
              end
            end
          end
          response = request.execute!
          response.xpath("//listitem").text
        rescue StandardError
          nil
        end
      end

      # FIXME: broken ([011003] Die Klasse '%s' wird nicht unterstützt.)
      def self.set(*args)
        username = language = nil
        raise ArgumentError, "set requires one or two parameters" unless [1, 2].include? args.length

        username, language = *args if args.length == 2
        language = *args if args.length == 1

        raise ArgumentError, "language cannot be nil" if language.nil?

        options = {}
        options = { login: username } if username

        begin
          request = XmlRequest.prepare do |xml|
            xml.tag!("userConfig.setTexts", options) do
              xml.tag!("dictitem") do
                xml.tag!("key") do
                  xml.text!("languages.language")
                end
                xml.tag!("value") do
                  xml.text!(language)
                end
              end
            end
          end
          response = request.execute!
          response.ok?
        rescue StandardError
          false
        end
      end
    end
  end
end
