module Reactor
  module Cm
    class XmlAttribute
      AVAILABLE_SCOPES = %i(get set create).freeze

      attr_accessor :name, :type, :scopes

      def initialize(name, type, options)
        @name = name
        @type = type.presence || :string

        @scopes =
          if options[:except].present?
            AVAILABLE_SCOPES - options[:except]
          elsif options[:only].present?
            options[:only]
          else
            AVAILABLE_SCOPES
          end
      end

      def scope?(name)
        scopes.include?(name)
      end
    end
  end
end
