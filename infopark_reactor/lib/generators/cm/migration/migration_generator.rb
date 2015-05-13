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
        if Reactor.rails4_0? || Reactor.rails4_1?
          migration_template "template.rb", "cm/migrate/#{file_name}.rb"
        else
          migration_template "template.rb", "cm/migrate/#{file_name}"
        end
      end
    end
  end
end
