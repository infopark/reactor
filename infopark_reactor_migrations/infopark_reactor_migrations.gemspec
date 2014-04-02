# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "reactor/migrations/version"

Gem::Specification.new do |s|
  s.name        = "infopark_reactor_migrations"
  s.version     = "#{Reactor::Migrations::VERSION}"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tomasz Przedmojski"]
  s.email       = ["tomasz.przedmojski@infopark.de"]
  s.homepage    = ""
  s.summary     = %q{The power of rails migrations for Inforpark Fiona CMS}
  s.description = %q{Create classes, attributes, store version information and synchronize multiple servers with one command.}
  s.license     = 'LGPL-3'

  #s.rubyforge_project = "infopark_reactor_migrations"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'rails', '>= 3.0.10', '<= 4.1.0'
  s.add_dependency 'term-ansicolor'
  s.add_dependency 'nokogiri'
  s.add_development_dependency 'rspec'
end
