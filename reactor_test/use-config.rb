#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'
require 'pp'

$CONFIGS = {
  'ruby2.1.2+Rails4.1.6+infopark_fiona_connector-41' => {
    '.ruby-version' => '2.1.2',
    'Gemfile' => <<-EOGEMFILE
source "https://rubygems.org"
gem "infopark_reactor", :path=>"../infopark_reactor"
gem "rspec-rails", "~> 2.0"
gem "infopark_fiona_connector", :git => "git@github.com:tomaszp-infopark/fiona_connector.git", :branch => 'rails4-1'
gem "mysql2"
gem "nokogiri", "< 1.6.0"
gem "rails", "4.1.6"
    EOGEMFILE
  },
  'ruby2.1.2+Rails4.0.9+infopark_fiona_connector-beta' => {
    '.ruby-version' => '2.1.2',
    'Gemfile' => <<-EOGEMFILE
source "https://rubygems.org"
gem "infopark_reactor", :path=>"../infopark_reactor"
gem "rspec-rails", "~> 2.0"
gem "infopark_fiona_connector", :git => "git@github.com:infopark/fiona_connector.git", :branch => 'dev'
gem "mysql2"
gem "nokogiri", "< 1.6.0"
gem "rails", "4.0.9"
    EOGEMFILE
  },
  'ruby2.1.2+Rails4.0.8+infopark_fiona_connector-beta' => {
    '.ruby-version' => '2.1.2',
    'Gemfile' => <<-EOGEMFILE
source "https://rubygems.org"
gem "infopark_reactor", :path=>"../infopark_reactor"
gem "rspec-rails", "~> 2.0"
gem "infopark_fiona_connector", :git => "git@github.com:infopark/fiona_connector.git", :branch => 'dev'
gem "mysql2"
gem "nokogiri", "< 1.6.0"
gem "rails", "4.0.8"
    EOGEMFILE
  },
  'ruby2.1.1+Rails4.0.3+infopark_fiona_connector-beta' => {
    '.ruby-version' => '2.1.1',
    'Gemfile' => <<-EOGEMFILE
source "https://rubygems.org"
gem "infopark_reactor", :path=>"../infopark_reactor"
gem "rspec-rails", "~> 2.0"
gem "infopark_fiona_connector", :git => "git@github.com:infopark/fiona_connector.git", :branch => 'top-level-fc'
gem "mysql2"
gem "nokogiri", "< 1.6.0"
gem "rails", "4.0.3"
    EOGEMFILE
  },
  'ruby2.0.0-p481+Rails3.2.19+infopark_fiona_connector-6.9.1.3.22208381' => {
    '.ruby-version' => '2.0.0-p481',
    'Gemfile' => <<-EOGEMFILE
source "https://rubygems.org"
gem "infopark_reactor", :path=>"../infopark_reactor"
gem "rspec-rails", "~> 2.0"
gem "infopark_rails_connector", "6.9.1.3.22208381"
gem "infopark_fiona_connector", "6.9.1.3.22208381"
gem "mysql2"
gem "rails", "3.2.19"
gem "nokogiri", "< 1.6.0"
    EOGEMFILE
  },
  'ruby1.9.3-p547+Rails3.2.20+infopark_fiona_connector-6.9.4' => {
    '.ruby-version' => '1.9.3-p547',
    'Gemfile' => <<-EOGEMFILE
source "https://rubygems.org"
gem "infopark_reactor", :path=>"../infopark_reactor"
gem "rspec-rails", "~> 2.0"
gem "infopark_rails_connector", "6.9.4"
gem "infopark_fiona_connector", "6.9.4"
gem "mysql2"
gem "rails", "3.2.20"
gem "nokogiri", "< 1.6.0"
    EOGEMFILE
  },
  'ruby1.9.3-p547+Rails3.2.19+infopark_fiona_connector-6.9.1.3.22208381' => {
    '.ruby-version' => '1.9.3-p547',
    'Gemfile' => <<-EOGEMFILE
source "https://rubygems.org"
gem "infopark_reactor", :path=>"../infopark_reactor"
gem "rspec-rails", "~> 2.0"
gem "infopark_rails_connector", "6.9.1.3.22208381"
gem "infopark_fiona_connector", "6.9.1.3.22208381"
gem "mysql2"
gem "rails", "3.2.19"
gem "nokogiri", "< 1.6.0"
    EOGEMFILE
  }
}

$DEFUALT = 'ruby2.1.2+Rails4.0.9+infopark_fiona_connector-beta'

$DAMN_YOU_RBENV = lambda {|command| "bash -c 'eval \"$(rbenv init -)\"; rbenv shell $(cat .ruby-version); #{command}'" }

class ConfigSetter
  def initialize(config)
    @config = config
  end

  def set!
    raise "Configuration not found" unless @config
    File.unlink('Gemfile.lock') if File.exists?('Gemfile.lock')
    @config.each do |file, content|
      File.open(file, 'w') do |f|
        f.write(content)
      end
    end
    system($DAMN_YOU_RBENV.call("bundle > /dev/null"))
  end
end

class CmdLine
  def self.parser
    opts = OptionParser.new do |opts|
      opts.banner = "Usage: #{File.basename __FILE__} [options] configuration"

      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-l", "--list", "List configurations") do
        $CONFIGS.keys.map {|k| puts k}
        exit
      end

      opts.on("-e", "--execute TASK", "Execute task for each configuration") do |task|
        $CONFIGS.each do |key, config|
          ConfigSetter.new(config).set!
          system($DAMN_YOU_RBENV.call(task)) || fail("Task '#{task}' on configuration #{key} returned a non-zero status.")
        end
        exit
      end

      opts.on("-d", "--describe", "Describe the available configurations") do
        pp $CONFIGS
        exit
      end

      # No argument, shows at tail.  This will print an options summary.
      # Try it and see!
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end
  end

  def self.show_help
    puts parser
    exit
  end

  # Return a structure describing the options.
  #
  def self.parse(args)
    parser.parse!(args)
    args
  end

end

configuration, _ = *CmdLine.parse(ARGV)

if configuration.nil?
  CmdLine.show_help
end

ConfigSetter.new($CONFIGS[configuration]).set!


