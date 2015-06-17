# -*- encoding : utf-8 -*-
module Cm
  module Generators
    class MigrationGenerator < Rails::Generators::NamedBase
      include Rails::Generators::Migration
      def self.next_migration_number(dirname)
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end

      source_root File.expand_path('../templates', __FILE__)
      def create_migration_file
        if Reactor.rails4_x?
          migration_template "template.rb", "cm/migrate/#{file_name}.rb"
        else
          migration_template "template.rb", "cm/migrate/#{file_name}"
        end
      end
    end
  end
end
