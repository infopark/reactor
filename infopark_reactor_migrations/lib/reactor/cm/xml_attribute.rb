module Reactor

  module Cm

    class XmlAttribute

      AVAILABLE_SCOPES = [:get, :set, :create]

      attr_accessor :name
      attr_accessor :type
      attr_accessor :scopes

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
        self.scopes.include?(name)
      end

    end

  end

end
