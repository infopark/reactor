RailsConnector::Configuration.instance_name = 'reactor'

# Enable Rails Connector Addons.
# Please refer to the Infopark Knowledge Base for more information on addons.
RailsConnector::Configuration.enable(
  :search
#  :time_machine,
#  :pdf_generator,
#  :comments,
#  :rss,
#  :omc
#  :ratings,
#  :google_analytics,
#  :infopark_tracking,
#  :seo_sitemap
)