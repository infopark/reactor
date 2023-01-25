module Cm
  module Generators
    class MigrationGenerator < Rails::Generators::NamedBase
      include Rails::Generators::Migration
      def self.next_migration_number(_dirname)
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end

      source_root File.expand_path("templates", __dir__)

      def create_migration_file
        migration_template "template.rb", "cm/migrate/#{file_name}.rb"
      end
    end
  end
end
