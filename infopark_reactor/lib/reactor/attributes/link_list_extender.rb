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
                detect_modification do
                  old.bind(self).call(*args, &block)
                end
              end if meth.to_sym != :map
            end

            def changed?
              @changed == true || temporary_links_present?
            end

            def change!
              @changed = true
            end

            def original_link_ids
              @original_link_ids ||= link_ids
            end

            protected
            def link_ids
              self.map(&:id).compact
            end

            def temporary_links_present?
              self.any? {|l| l.kind_of? Reactor::Link::TemporaryLink }
            end

            def detect_modification(&block)
              original_link_ids
              yield.tap do
                @changed = @changed || original_link_ids != link_ids
              end
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
