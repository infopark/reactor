# -*- encoding : utf-8 -*-
# @author Anton Mezin
module RailsConnector
  class Channel < AbstractModel
    self.primary_key = "channel_name"

    def self.table_name
      "#{table_name_prefix}" "channels"
    end

    has_many :news, :class_name => 'News', :foreign_key => 'channel_name'

    if ::Rails::VERSION::MAJOR == 4

      has_many :active_news, 
        lambda { where(['valid_from <= :now AND valid_until >= :now', {:now => Time.now.to_s(:number)}]) },
        :class_name => 'News', :foreign_key => 'channel_name'

      if ::Rails::VERSION::MINOR >= 1

        def self.scoped
          self.where(nil)
        end

      end

    elsif ::Rails::VERSION::MAJOR == 3

      has_many :active_news, :class_name => 'News', :foreign_key => 'channel_name',
        :conditions => ['valid_from <= :now AND valid_until >= :now', {:now => Time.now.to_s(:number)}]

    end

    has_many :objects, :through => :news

    def self.with_prefix(prefix)
      scoped.where(["channel_name LIKE ?", "#{prefix}%"])
    end

  end
end
