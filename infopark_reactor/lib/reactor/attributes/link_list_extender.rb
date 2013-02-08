# -*- encoding : utf-8 -*-
require 'reactor/link/temporary_link'

module Reactor
  module Attributes
    module LinkListExtender
      def self.extend_linklist!
        # this will trigger rails autoload
        extend_given_linklist!(RailsConnector::LinkList)
      end

      def self.extend_given_linklist!(klass)
        unless klass.instance_methods(false).include?("changed?")
          klass.class_eval do
            def <<(link_data)
              super(transform_into_link(link_data))
            end

            # install #size_changed callback
            Array.instance_methods(false).each do |meth|
              old = instance_method(meth)
              define_method(meth) do |*args, &block|
                old_size = size
                ret = old.bind(self).call(*args, &block)
                size_changed(old_size, size) if old_size != size
                ret
              end if meth.to_sym != :size
            end

            def changed?
              @changed == true
            end

            protected
            def size_changed(old_size, size)
              @changed = true
            end

            def transform_into_link(link_data)
              if (link_data.respond_to?(:external?) && link_data.respond_to?(:internal?))
                link_data
              else
                Reactor::Link::TemporaryLink.new(link_data)
              end
            end
          end
        end
      end
    end
  end
end
