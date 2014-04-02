# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "meta/version"

Gem::Specification.new do |s|
  s.name        = "infopark_rails_connector_meta"
  s.version     = RailsConnector::Meta::VERSION
  s.authors     = ["Tomasz Przedmojski"]
  s.email       = ["tomasz.przedmojski@infopark.de"]
  s.homepage    = ""
  s.summary     = %Q{Meta Information on CMS Objects}
  s.description = %Q{Gives RailsConnector Objs information about its CMS class, attributes, etc.}
  s.license	= 'LGPL-3'

  #s.rubyforge_project = "infopark_rails_connector_meta"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"

  s.add_runtime_dependency "activerecord", '>= 3.0.10', '<= 4.1.0'
  s.add_runtime_dependency "activesupport", '>= 3.0.10', '<= 4.1.0'
  #s.add_runtime_dependency "infopark_rails_connector"
end
