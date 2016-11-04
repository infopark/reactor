# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "reactor/version"

Gem::Specification.new do |s|
  s.name        = "infopark_reactor"
  s.version     = "#{Reactor::VERSION}"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tomasz Przedmojski"]
  s.email       = ["tomasz.przedmojski@infopark.de"]
  s.homepage    = ""
  s.summary     = %q{Write into CM in familiar, Rails-like way}
  s.description = %q{Use the ActiveRecord mimicking API to write into CM and enjoy all the benefits of callbacks, validations and permission checking}
  s.license     = 'LGPL-3'

  #s.rubyforge_project = "infopark_reactor"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'rails', '>= 3.0.10', '< 4.3.0'
  #s.add_dependency 'infopark_rails_connector'
  s.add_dependency 'nokogiri'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'yard'
end
