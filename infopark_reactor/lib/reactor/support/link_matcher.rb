# -*- encoding : utf-8 -*-
module Reactor
  module Support
    class LinkMatcher
      def initialize(url)
        @url = url
      end

      def recognized?
        match = match_url
        (match[:action] == "index") &&
          (match[:controller] == "rails_connector/cms_dispatch") &&
          ((match[:id].present? && Obj.exists?(match[:id].to_i)) ||
          (match[:permalink].present? && Obj.exists?(:permalink => match[:permalink])))
      rescue ActionController::RoutingError
        return false
      end

      def rewrite_url
        match = match_url

        if match[:permalink].present?
          append_fragment_and_query Obj.find_by_permalink(match[:permalink]).path 
        elsif match[:id].present?
          append_fragment_and_query Obj.find(match[:id].to_i).path
        end
      end

      private
      def match_url
        relative_url_root = ENV['RAILS_RELATIVE_URL_ROOT']
        url = @url.clone
        url.gsub!(/^#{Regexp.escape(relative_url_root)}/, '') if relative_url_root.present?
        Rails.application.routes.recognize_path(url)
      end

      def append_fragment_and_query(obj_path)
        uri = URI.parse(@url)
        obj_path += "?#{uri.query}" if uri.query
        obj_path += "##{uri.fragment}" if uri.fragment
        obj_path
      end
    end
  end
end
