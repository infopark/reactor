require "reactor/link/temporary_link"

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

            def []=(idx, value)
              super(idx, transform_into_link(value))
            end

            # install #size_changed callback
            Array.instance_methods(false).each do |meth|
              old = instance_method(meth)
              next unless meth.to_sym != :map

              define_method(meth) do |*args, &block|
                detect_modification do
                  old.bind(self).call(*args, &block)
                end
              end
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
              map(&:id).compact
            end

            def temporary_links_present?
              any? { |l| l.is_a? Reactor::Link::TemporaryLink }
            end

            def detect_modification
              original_link_ids
              yield.tap do
                @changed ||= original_link_ids != link_ids
              end
            end

            def transform_into_link(link_data)
              if link_data.respond_to?(:external?) && link_data.respond_to?(:internal?)
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
