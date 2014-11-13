# -*- encoding : utf-8 -*-
module Reactor

  module Plans

    class RenameGroup

      include Prepared

      def initialize(*args)
        (from, to), options = separate_arguments(*args)

        @from = from || options[:from]
        @to = to || options[:to]
      end

      def prepare!
        error('from is nil') if @from.nil?
        error('to is nil') if @to.nil?
        error('from does not exist') unless Reactor::Cm::Group.exists?(@from)
        error('to does exist') if Reactor::Cm::Group.exists?(@to)
      end

      def migrate!
        group = Reactor::Cm::Group.get(@from)
        group.rename!(@to)
      end

    end

  end

end
