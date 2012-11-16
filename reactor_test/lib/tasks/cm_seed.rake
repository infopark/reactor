namespace :cm do
  namespace :seed do
    desc "Load test fixtures"
    task :test => :environment do
      require "#{Rails.root}/cm/seeds-test.rb"
    end
  end
end