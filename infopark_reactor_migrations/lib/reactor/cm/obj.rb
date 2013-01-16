module Reactor
  module Cm
    class Obj
      attr_reader :obj_id
      OBJ_ATTRS = [:permalink, :objClass, :workflowName, :name, :suppressExport, :parent] 
      ATTR_LENGTH_CONSTRAINT = {:name => 250, :title => 250}

      def self.create(name, parent, objClass)
        obj = Obj.new(name)
        obj.send(:create, parent, objClass)
        obj
      end

      def self.exists?(path_or_id)
        obj = Obj.new
        begin
          obj.send(:load, path_or_id).ok?
        rescue
          return false
        end
      end

      def self.get(path_or_id)
        obj = Obj.new
        obj.send(:load, path_or_id)
        obj
      end

      def self.delete_where(conditions)
        request = XmlRequest.prepare do |xml|

          xml.tag!('obj-where') do
            conditions.each do |key, value|
              xml.tag!(key, value)
            end
          end
          xml.tag!("obj-delete")
        end
        request.execute!
      end

      def upload(data_or_io, extension)
        data = (data_or_io.kind_of?IO) ? data_or_io.read : data_or_io
        base64_data = Base64.encode64(data)

        set(:contentType, extension)
        set(:blob, {base64_data=>{:encoding=>'base64'}})
      end

      def get(key)
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, 'id', @obj_id)
          xml.get_key_tag!(base_name, key)
        end
        response = request.execute!
        result = response.xpath("//#{key}")
        if result.children.map {|i| i.respond_to?(:name) && (i.name == "listitem") }.reduce(:&)
          result.children.map {|i| i.text.to_s }
        else
          result = result.text unless result.is_a? Array
          result
        end
      end

      def set(key, value, options={})
        key = key.to_sym
        value = value[0, ATTR_LENGTH_CONSTRAINT[key]] if ATTR_LENGTH_CONSTRAINT[key]
        if OBJ_ATTRS.include?(key) then @obj_attrs[key] = value
        else
          @attrs[key] = value
        end
        @attr_options[key] = options
      end

      def permission_granted_to(user, permission)
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, 'id', @obj_id)
          xml.get_tag!(base_name) do
            xml.tag!('permissionGrantedTo', :permission => permission, :user => user)
          end
        end
        response = request.execute!
        response.xpath("//permissionGrantedTo/text()") == "1"
      end

      def permission_set(permission, groups)
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, :id, @obj_id)

          options = {
            :permission => permission,
            :type => :list,
          }

          xml.set_key_tag!(base_name, :permission, groups, options)
        end

        request.execute!
      end

      def permission_grant(permission, groups)
        self.permission_command('GrantTo', permission, groups)
      end

      def permission_revoke(permission, groups)
        self.permission_command('RevokeFrom', permission, groups)
      end

      def permission_clear(permission)
        self.permission_set(permission, [])
      end

      def get_links(attr)
        get_link_ids(attr).map {|id| Link.get(id)}
      end

      def set_links(attr, new_links_as_hashes)
        get_links(attr).map(&:delete!)
        new_links_as_hashes.each do |link_hash|
          Link.create_inside(self, attr, link_hash[:destination_url], link_hash[:title])
        end
      end

      def set_link(attr, path)
        old_links = get_links(attr)
        if old_links.length == 1
          old_link = old_links.first
          old_link.dest_url = path
          @links[attr] = [old_link]
        else
          @removed_links = old_links
          @links[attr] = [Link.create_inside(self, attr, path)]
        end
      end

      def save!
        edit! if not edited?
        content = edited_content
        @request = XmlRequest.prepare do |xml|
          xml.where_key_tag!('content', 'id', content)
          xml.tag!("content-set") do
            @attrs.each do |key, value|
              if (@attr_options[key] || {})[:cdata]
                xml.tag!(key.to_s) do
                  xml.cdata!(value)
                end
              else
                xml.value_tag!(key.to_s, value)
              end
            end
          end
        end
        response = @request.execute!
        return response if !response.ok?

        unless @obj_attrs.empty?
          request = XmlRequest.prepare do |xml|
            xml.where_key_tag!(base_name, 'id', @obj_id)
            xml.set_tag!(base_name) do
              @obj_attrs.each do |key, value|
                xml.value_tag!(key, value)
              end
            end
          end
          response = request.execute!
        end

        return response if !response.ok?

        @removed_links.each do |link|
          link.delete!
        end

        @links.each do |attr, links|
          links.each do |link|
            link.save!
          end
        end
      end


      def release!
        simple_command("release")
      end

      def edit!
        simple_command("edit")
      end

      def take!
        simple_command("take")
      end

      def forward!
        simple_command("forward")
      end

      def commit!
        simple_command("commit")
      end

      def reject!
        simple_command("reject")
      end

      def sign!
        simple_command("sign")
      end

      def valid_actions
        vcak = get('validControlActionKeys')
        (vcak || []).map(&:to_s)
      end

      def copy(new_parent, recursive = false, new_name = nil)
        request = XmlRequest.prepare do |xml|
          xml.tag!('obj-where') do
            xml.tag!("id", @obj_id)
          end
          xml.tag!("obj-copy") do
            xml.tag!("parent", new_parent)
            xml.tag!("name", new_name) if new_name
            xml.tag!("recursive", "1") if recursive
          end
        end
        response = request.execute!
        response.xpath("//obj/id").text
      end

      def delete!
        simple_command("delete")
      end

      def remove_active_contents!
        simple_command("removeActiveContents")
      end

      def remove_archived_contents!
        simple_command("removeArchivedContents")
      end

      def resolve_refs!
        request = XmlRequest.prepare do |xml|
          xml.tag!('content-where') do
            xml.tag!('objectId', @obj_id)
            xml.tag!('state', 'edited')
          end
          xml.tag!('content-resolveRefs')
        end
        response = request.execute!
      end

      def path
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, 'id', @obj_id)
          xml.get_key_tag!(base_name, 'path')
        end
        response = request.execute!
        response.xpath("//obj/path").text
      end

      def edited?
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, 'id', @obj_id)
          xml.get_key_tag!(base_name, 'isEdited')
        end
        response = request.execute!
        response.xpath("//isEdited").text == "1"
      end

      def reasons_for_incomplete_state
        request = XmlRequest.prepare do |xml|
          xml.tag!('content-where') do
            xml.tag!('objectId', @obj_id)
            xml.tag!('state', 'edited')
          end
          xml.get_key_tag!('content', 'reasonsForIncompleteState')
        end
        response = request.execute!
        result = response.xpath('//reasonsForIncompleteState/*')
        result.kind_of?(Array) ? result.map(&:text).map(&:to_s) : [result.to_s]
      end

      def editor
        request = XmlRequest.prepare do |xml|
          xml.tag!('content-where') do
            xml.tag!('objectId', @obj_id)
            xml.tag!('state', 'edited')
          end
          xml.get_key_tag!('content', 'editor')
        end
        response = request.execute!
        response.xpath('//editor').text
      end

      def edited_content
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, 'id', @obj_id)
          xml.get_key_tag!(base_name, 'editedContent')
        end
        response = request.execute!
        response.xpath("//editedContent").text
      end

      protected
      def simple_command(cmd_name)
        @request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, 'id', @obj_id)
          xml.tag!("#{base_name}-#{cmd_name}")
        end
        response = @request.execute!
      end

      def base_name
        'obj'
      end

      def get_content_attr_text(attr)
        content = edited_content
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!('content', 'id', content)
          xml.get_tag!('content') do
            xml.tag!(attr.to_s)
          end
        end
        response = request.execute!
        txt = response.xpath("//#{attr}/text()")
        txt.class.unnormalize(txt.to_s)
      end

      def get_link_ids(attr)
        content = edited_content
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!('content', 'id', content)
          xml.get_key_tag!('content', attr.to_s)
        end
        response = request.execute!
        result = response.xpath("//listitem/text()")
        result.kind_of?(Array) ? result : [result]
      rescue XmlRequestError
        []
      end

      def self.extract_id(response)
        response.xpath("//obj/id").text
      end

      def initialize(name=nil)
        @name = name
        @attrs = {}
        @obj_attrs = {}
        @links = {}
        @removed_links = []
        @attr_options = {}
      end

      def create(parent, objClass)
        @request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, 'path', parent)
          xml.create_tag!(base_name) do
            xml.tag!('objClass') do
              xml.text!(objClass)
            end
            xml.tag!('name') do
              xml.text!(@name)
            end
          end
        end
        response = @request.execute!
        @obj_id = self.class.extract_id(response)
        response
      end

      def load(path_or_id)
        key = (/^\// =~ path_or_id.to_s) ? 'path' : 'id'
        value = path_or_id

        @request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, key.to_s, value.to_s)
          xml.get_key_tag!(base_name, 'id')
        end
        response = @request.execute!
        @obj_id = self.class.extract_id(response)
        response
      end

      def permission_command(type, permission, groups)
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, 'id', @obj_id)

          xml.tag!("#{base_name}-permission#{type}", :permission => permission) do
            groups.each do |name|
              xml.tag!(:group, name)
            end
          end
        end

        request.execute!
      end
    end
  end
end
