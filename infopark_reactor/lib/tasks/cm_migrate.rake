namespace :cm do
  desc "Migrate CM"
  task :migrate => :environment do
    require 'reactor/tools/migrator'
    migrator = Reactor::Migrator.new("#{Rails.root}/cm/migrate", ENV["VERSION"])
    migrator.migrate
  end
end
