#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'
require 'pp'

$CONFIGS = {
  'ruby2.2.6+Rails4.2.7.1+infopark_fiona_connector-7.0.1' => {
    '.ruby-version' => '2.2.6',
    'Gemfile' => <<-EOGEMFILE
source "https://rubygems.org"
gem "infopark_reactor", :path=>"../infopark_reactor"
gem "rspec-rails", "~> 2.0"
gem "infopark_fiona_connector", '7.0.1'
gem "mysql2"
gem "nokogiri"
gem "rails", "4.2.7.1"
    EOGEMFILE
  },
  'ruby2.2.6+Rails4.2.7.1+infopark_fiona_connector-7.0.1.beta2' => {
    '.ruby-version' => '2.2.6',
    'Gemfile' => <<-EOGEMFILE
source "https://rubygems.org"
gem "infopark_reactor", :path=>"../infopark_reactor"
gem "rspec-rails", "~> 2.0"
gem "infopark_fiona_connector", '7.0.1.beta2'
gem "mysql2"
gem "nokogiri"
gem "rails", "4.2.7.1"
    EOGEMFILE
  },
  'ruby2.2.4+Rails4.1.14+infopark_fiona_connector-7.0.0' => {
    '.ruby-version' => '2.2.4',
    'Gemfile' => <<-EOGEMFILE
source "https://rubygems.org"
gem "infopark_reactor", :path=>"../infopark_reactor"
gem "rspec-rails", "~> 2.0"
gem "infopark_fiona_connector", '7.0.0'
gem "mysql2"
gem "nokogiri", "< 1.6.0"
gem "rails", "4.1.14"
    EOGEMFILE
  },
  'ruby2.1.8+Rails4.1.14+infopark_fiona_connector-7.0.0' => {
    '.ruby-version' => '2.1.8',
    'Gemfile' => <<-EOGEMFILE
source "https://rubygems.org"
gem "infopark_reactor", :path=>"../infopark_reactor"
gem "rspec-rails", "~> 2.0"
gem "infopark_fiona_connector", '7.0.0'
gem "mysql2"
gem "nokogiri", "< 1.6.0"
gem "rails", "4.1.14"
    EOGEMFILE
  },
  'ruby2.1.8+Rails4.1.14+infopark_fiona_connector-6.10.0.beta1' => {
    '.ruby-version' => '2.1.8',
    'Gemfile' => <<-EOGEMFILE
source "https://rubygems.org"
gem "infopark_reactor", :path=>"../infopark_reactor"
gem "rspec-rails", "~> 2.0"
gem "infopark_fiona_connector", '6.10.0.beta1'
gem "mysql2"
gem "nokogiri", "< 1.6.0"
gem "rails", "4.1.14"
    EOGEMFILE
  },
  'ruby2.1.8+Rails4.0.13+infopark_fiona_connector-beta' => {
    '.ruby-version' => '2.1.8',
    'Gemfile' => <<-EOGEMFILE
source "https://rubygems.org"
gem "infopark_reactor", :path=>"../infopark_reactor"
gem "rspec-rails", "~> 2.0"
gem "infopark_fiona_connector", :git => "git@github.com:infopark/fiona_connector.git", :ref => '9c9ee921dc1b66a11e4620d1c1a688d7d4e50fdd'
gem "mysql2"
gem "nokogiri", "< 1.6.0"
gem "rails", "4.0.13"
    EOGEMFILE
  },
  'ruby2.0.0-p648+Rails3.2.22.2+infopark_fiona_connector-6.9.1.3.22208381' => {
    '.ruby-version' => '2.0.0-p648',
    'Gemfile' => <<-EOGEMFILE
source "https://rubygems.org"
gem "infopark_reactor", :path=>"../infopark_reactor"
gem "rspec-rails", "~> 2.0"
gem "infopark_rails_connector", "6.9.1.3.22208381"
gem "infopark_fiona_connector", "6.9.1.3.22208381"
gem "mysql2"
gem "rails", "3.2.22.2"
gem "nokogiri", "< 1.6.0"
    EOGEMFILE
  },
  'ruby1.9.3-p547+Rails3.2.22+infopark_fiona_connector-6.9.4' => {
    '.ruby-version' => '1.9.3-p547',
    'Gemfile' => <<-EOGEMFILE
source "https://rubygems.org"
gem "infopark_reactor", :path=>"../infopark_reactor"
gem "rspec-rails", "~> 2.0"
gem "infopark_rails_connector", "6.9.4"
gem "infopark_fiona_connector", "6.9.4"
gem "mysql2"
gem "rails", "3.2.22"
gem "nokogiri", "< 1.6.0"
gem "json", "< 2.0" # any newer version is incompatible with ruby 1.9
gem "tins", "< 1.3" # any newer version is incompatible with ruby 1.9
    EOGEMFILE
  },
  'ruby1.9.3-p547+Rails3.2.12+infopark_fiona_connector-6.9.1.3.22208381' => {
    '.ruby-version' => '1.9.3-p547',
    'Gemfile' => <<-EOGEMFILE
source "https://rubygems.org"
gem "infopark_reactor", :path=>"../infopark_reactor"
gem "rspec-rails", "~> 2.0"
gem "infopark_rails_connector", "6.9.1.3.22208381"
gem "infopark_fiona_connector", "6.9.1.3.22208381"
gem "mysql2"
gem "rails", "3.2.22"
gem "nokogiri", "< 1.6.0"
gem "json", "< 2.0" # any newer version is incompatible with ruby 1.9
gem "tins", "< 1.3" # any newer version is incompatible with ruby 1.9
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
    system($DAMN_YOU_RBENV.call("bundle "))
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
          ConfigSetter.new(config).set! || fail("Configuration #{key} broken.")
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


