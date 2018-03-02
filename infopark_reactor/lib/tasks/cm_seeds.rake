namespace :cm do

  desc "Load the seed data from cm/seeds.rb"
  task :seed => :environment do
    require 'reactor/tools/sower'
    sower = Reactor::Sower.new("#{Rails.root}/cm/seeds.rb")
    sower.sow
  end

  namespace :seed do

    desc "Load the seed data from cm/seeds-develop.rb"
    task :develop => :environment do
      require 'reactor/tools/sower'
      sower = Reactor::Sower.new("#{Rails.root}/cm/seeds-develop.rb")
      sower.sow
    end

    task :test => :environment do
      require 'reactor/tools/sower'
      sower = Reactor::Sower.new("#{Rails.root}/cm/seeds-test.rb")
      sower.sow
    end
  end

  namespace :maintenance do

    Dir["#{Rails.root}/cm/maintenance-scripts/*.rb"].each do |maint_script|

      desc "Execute seed in cm/maintenance-scripts/#{File.basename(maint_script)}"
      task File.basename(maint_script, '.rb').to_sym => :environment do
        require 'reactor/tools/sower'
        sower = Reactor::Sower.new(maint_script)
        sower.sow
      end

    end

  end

end
