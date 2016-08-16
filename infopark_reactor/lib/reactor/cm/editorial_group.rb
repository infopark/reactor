# -*- encoding : utf-8 -*-
require 'reactor/cm/group'

module Reactor

  module Cm

    # The EditorialGroup class respects the user management configured in the content manager and
    # handles all editorial groups. See @Group for further details.
    class EditorialGroup < Group

      primary_key :name

      protected

      # Overwritten method from +Group+.
      def base_name
        'groupProxy'
      end

    end

  end

end
