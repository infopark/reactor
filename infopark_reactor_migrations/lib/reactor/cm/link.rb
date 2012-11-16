module Reactor
  module Cm
    class Link
      attr_reader :link_id, :dest_obj_id, :dest_url
      attr_accessor :title, :target, :position

      def self.exists?(id)
        return !Link.get(id).nil?
      rescue XmlRequestError => e
        return false
      end

      def self.get(id)
        link = Link.new
        link.send(:get,id)
        link
      end

      def self.create_inside(obj, attr, url, title=nil)
        create(obj.edited_content, attr, url, title)
      end

      def self.create(content, attr, url, title=nil)
        link = Link.new
        link.send(:create, content, attr, url, title)
        link
      end

      def is_external?
        @is_external == true
      end

      def is_internal?
        !is_external?
      end

      def dest_obj_id=(obj_id)
        @is_external  = false
        @dest_url     = Obj.get(obj_id).path
        @dest_obj_id  = obj_id
      end

      def dest_url=(url)
        @is_external  = (/^\// =~ url).nil?
        @dest_obj_id  = Obj.get(url).obj_id unless @is_external
        @dest_url     = url
      end

      def save!
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, 'id', @link_id)
          xml.set_tag!(base_name) do
            xml.tag!('target', @target) if @target
            xml.tag!('title', @title) if @title
            xml.tag!('destinationUrl', @dest_url) if @dest_url
            xml.tag!('position', @position) if @position
          end
        end
        response = request.execute!
      end

      def hash
        # yes, to_s.to_is is neccesary,
        # because self.link_id is of type REXML::Text for the most of the time
        self.link_id.to_s.to_i
      end


      def eql?(other)
        self.link_id == other.link_id
      end

      def delete!
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, 'id', @link_id)
          xml.tag!("#{base_name}-delete")
        end
        response = request.execute!
      end

      protected
      def initialize
      end

      def base_name
        'link'
      end

      def get(id)
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, 'id', id)
          xml.get_key_tag!(base_name, ['id', 'isExternalLink', 'target', 'title', 'destination', 'destinationUrl', 'position'])
        end
        response      = request.execute!

        @link_id      = response.xpath('//id/text()')
        @is_external  = response.xpath('//isExternalLink/text()') == '1'
        @target       = response.xpath('//target/text()').presence
        @title        = response.xpath('//title/text()').presence
        @dest_obj_id  = response.xpath('//destination/text()').presence
        @dest_url     = response.xpath('//destinationUrl/text()').presence
        @position     = response.xpath('//position/text()').presence

        self
      end

      def create(content, attr, url, title = nil)
        request = XmlRequest.prepare do |xml|
          xml.create_tag!(base_name) do
            xml.tag!('attributeName', attr.to_s)
            xml.tag!('sourceContent', content.to_s)
            xml.tag!('destinationUrl', url.to_s)
          end
        end
        response = request.execute!

        id = response.xpath('//id/text()')
        get(id)

        if !title.nil?
          request = XmlRequest.prepare do |xml|
            xml.where_key_tag!(base_name, 'id', id)
            xml.set_key_tag!(base_name, 'title', title)
          end
          response = request.execute!
        end

        self
      end
    end
  end
end