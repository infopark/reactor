# -*- encoding : utf-8 -*-
require 'reactor/cm/multi_xml_request'

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

      def self.load(id)
        obj = Obj.new
        obj.instance_variable_set('@obj_id', id)
        obj
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
        value = value[0, ATTR_LENGTH_CONSTRAINT[key]] if ATTR_LENGTH_CONSTRAINT[key] && value
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
          Link.create_inside(self, attr, link_hash[:destination_url], link_hash[:title], link_hash[:target])
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

      def set_multiple(attrs)
        attrs.each {|a,(v,o)| set(a,v,o||{}) }
      end

      def composite_save(attrs, links_to_add, links_to_remove, links_to_set, links_modified=false)
        set_multiple(attrs)

        skip_version_creation = @attrs.empty? && links_to_remove.empty? && links_to_set.empty? && !links_modified

        # The save procedure consists of two multiplexed CM requests.
        # Each request combines multiple operations for better performance.
        #
        # It is necessary to split the procedure into two request because
        # of the linklist handling. For objects with only released content
        # the edit operation copies all links (and generates new ids).
        # Only the new links from the edited content can be manipulated.
        # Thus it is neccessary after perform a read of links after the
        # edit operation.
        #
        # The second request may seem strange and redundant, but has very
        # important reasons for being structured the way it is.
        # The CM in all versions (as of this moment <= 7.0.1) contains
        # multiple race conditions regarding slave workers and the CRUL
        # interface.
        #
        # It is possible that the two requests are processed by two different
        # slave workers which have an invalid cache. Without careful
        # programing it may lead to unexpected results and/or data loss.
        # The reason behind it is simple: the cache invalidate requests
        # are distributed asynchronously between workers.
        #
        # It is impossible to ensure that the two requests are processed
        # by the same worker: a worker may get killed at any time, without
        # warning (producing errors on keep-alive connections). Furthermore
        # the workers regularly kill themselves (after X processed requests)
        # to contain memory leaks.
        #
        # Following cases are especially important to handle correctly:
        # Let Slave 1 be the worker receiving the first request and Slave 2
        # be the worker receiving the second request. Let Object be the
        # object on which the save operation is performed.
        #
        # 1. If the Object contains only released version, then Slave 2
        # may be unaware of the newly created edited version by the time
        # the second request is being processed. Thefore all operations
        # involving indirect content references for example adding links
        # (obj where ... editedContent addLinkTo) would get rejected
        # by the Slave 2.
        #
        # 2. If the Object contains an edited version, then Slave 2 may
        # be unaware of the changes perfomed on it, change of editor for
        # example, and can reject valid requests. The more dramatic
        # scenario involves Slave 2 persisting its invalid cached content
        # which would result in a data loss.
        #
        # The requests have been thus crafted to deal with those problems.
        # The solution is based on the precise source-code level knowledge
        # of the CM internals.
        resp = MultiXmlRequest.execute do |reqs|
          reqs.optional  {|xml| SimpleCommandRequest.build(xml, @obj_id, 'take') } unless skip_version_creation
          reqs.optional  {|xml| SimpleCommandRequest.build(xml, @obj_id, 'edit') } unless skip_version_creation


          reqs.mandatory {|xml| ObjSetRequest.build(xml, @obj_id, @obj_attrs) } unless @obj_attrs.empty? #important! requires different permissions
          reqs.mandatory {|xml| ContentSetRequest.build(xml, @obj_id, @attrs, @attr_options) } unless skip_version_creation
          reqs.mandatory  {|xml| ResolveRefsRequest.build(xml, @obj_id) } unless skip_version_creation
        end

        resp.assert_success

        yield(attrs, links_to_add, links_to_remove, links_to_set) if block_given?

        resp = MultiXmlRequest.execute do |reqs|
          reqs.optional  {|xml| SimpleCommandRequest.build(xml, @obj_id, 'take') }
          reqs.optional  {|xml| SimpleCommandRequest.build(xml, @obj_id, 'edit') }

          links_to_remove.each do |link_id|
            reqs.mandatory {|xml| LinkDeleteRequest.build(xml, link_id) }
          end

          links_to_set.each do |(link_id, link)|
            reqs.mandatory {|xml| LinkSetRequest.build(xml, link_id, link) }
          end

          links_to_add.each do |(attr, link)|
            reqs.mandatory {|xml| LinkAddRequest.build(xml, @obj_id, attr, link) }
          end
        end unless skip_version_creation || (links_to_remove.empty? && links_to_add.empty? && links_to_set.empty?)

        resp.assert_success
      end

      def save!
        links_to_remove = @removed_links.map {|l| l.link_id}
        links_to_add = @links.map do |attr, links|
          links.map do |link|
            [attr, {:destination_url => link.dest_url, :title => link.title, :target => link.target, :position => link.position}]
          end.flatten
        end
        composite_save([], links_to_add, links_to_remove, [])
      end


      def release!(msg=nil)
        simple_command("release",msg)
      end

      def edit!(msg=nil)
        simple_command("edit",msg)
      end

      def take!(msg=nil)
        simple_command("take",msg)
      end

      def forward!(msg=nil)
        simple_command("forward",msg)
      end

      def commit!(msg=nil)
        simple_command("commit",msg)
      end

      def reject!(msg=nil)
        simple_command("reject",msg)
      end

      def revert!(msg=nil)
        simple_command("revert",msg)
      end

      def sign!(msg=nil)
        simple_command("sign",msg)
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

      def workflow_comment
        request = XmlRequest.prepare do |xml|
          xml.tag!('content-where') do
            xml.tag!('objectId', @obj_id)
            xml.tag!('state', 'released')
          end
          xml.get_key_tag!('content', 'workflowComment')
        end
        response = request.execute!
        result = response.xpath('//workflowComment/*').map {|x| x.text.to_s}.first
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
      def simple_command(cmd_name, comment=nil)
        @request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, 'id', @obj_id)
          if comment
            xml.tag!("#{base_name}-#{cmd_name}") do
              xml.tag!('comment', comment)
            end
          else
            xml.tag!("#{base_name}-#{cmd_name}")
          end
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

      class Request
        attr_reader :xml

        def initialize(xml)
          @xml = xml
        end

        def self.build(xml, *args)
          self.new(xml).build(*args)
        end
      end

      class SimpleCommandRequest < Request
        def build(obj_id, cmd_name, comment = nil)
          xml.where_key_tag!('obj', 'id', obj_id)
          if comment
            xml.tag!("obj-#{cmd_name}") do
              xml.tag!('comment', comment)
            end
          else
            xml.tag!("obj-#{cmd_name}")
          end
        end
      end

      class ObjSetRequest < Request
        def build(obj_id, obj_attrs)
          xml.where_key_tag!('obj', 'id', obj_id)
          xml.set_tag!('obj') do
            obj_attrs.each do |key, value|
              xml.value_tag!(key, value)
            end
          end
        end
      end

      class ContentSetRequest < Request
        def build(id, attrs, attr_options)
          xml.tag!('content-where') do
            xml.tag!('objectId', id.to_s)
            xml.tag!('state', 'edited')
          end
          xml.tag!("content-set") do
            attrs.each do |key, value|
              if (attr_options[key] || {})[:cdata]
                xml.tag!(key.to_s) do
                  xml.cdata!(value)
                end
              else
                xml.value_tag!(key.to_s, value)
              end
            end
          end
        end
      end

      class LinkDeleteRequest < Request
        def build(link_id)
          xml.where_key_tag!('link', 'id', link_id)
          xml.tag!("link-delete")
        end
      end

      class LinkAddRequest < Request
        def build(obj_id, attr, link_data)
          title = link_data[:title]
          target = link_data[:target]
          xml.tag!('content-where') do
            xml.tag!('objectId', obj_id.to_s)
            xml.tag!('state', 'edited')
          end
          xml.tag!('content-addLinkTo') do
            xml.tag!('attribute', attr.to_s)
            xml.tag!('destinationUrl', link_data[:destination_url].to_s)
            xml.tag!('title', title.to_s) if title
            xml.tag!('target', target.to_s) if target
          end
        end
      end

      class LinkSetRequest < Request
        def build(link_id, link_data)
          title = link_data[:title]
          target = link_data[:target]
          xml.tag!('link-where') do
            xml.tag!('id', link_id)
          end
          xml.tag!('link-set') do
            xml.tag!('destinationUrl', link_data[:destination_url].to_s)
            xml.tag!('title', title.to_s)
            xml.tag!('target', target.to_s)
          end
        end
      end

      class ResolveRefsRequest < Request
        def build(obj_id)
          xml.tag!('content-where') do
            xml.tag!('objectId', obj_id.to_s)
            xml.tag!('state', 'edited')
          end
          xml.tag!('content-resolveRefs')
        end
      end
    end
  end
end
