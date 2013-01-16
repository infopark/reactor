# @author Anton Mezin
module RailsConnector
  class Channel < InfoparkBase
    self.primary_key = "channel_name"

    def self.table_name
      "#{table_name_prefix}" "channels"
    end

    has_many :news, :class_name => 'News', :foreign_key => 'channel_name'

    has_many :active_news, :class_name => 'News', :foreign_key => 'channel_name',
      :conditions => ['valid_from <= :now AND valid_until >= :now', {:now => Time.now.to_s(:number)}]

    has_many :objects, :through => :news

    def self.with_prefix(prefix)
      scoped.where(["channel_name LIKE ?", "#{prefix}%"])
    end

  end
end
