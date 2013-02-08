# -*- encoding : utf-8 -*-
module Reactor
  module Migrations
    class Railtie < Rails::Railtie
      rake_tasks do
        load "tasks/cm_migrate.rake"
        load "tasks/cm_seeds.rake"
      end
    end
  end
end
