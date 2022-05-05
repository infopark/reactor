$:.push File.expand_path("lib", __dir__)
require "reactor/version"

Gem::Specification.new do |s|
  s.name        = "infopark_reactor"
  s.version     = Reactor::VERSION.to_s
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tomasz Przedmojski", "Anton Mezin", "Roman Lemekha"]
  s.email       = ["tomasz.przedmojski@infopark.de", "anton.mezin@infopark.de", "roman.lemekha@infopark.de"]
  s.homepage    = "https://www.justrelate.com/"
  s.summary     = "Write into CM in familiar, Rails-like way"
  s.description = "Use the ActiveRecord mimicking API to write into CM and enjoy all the benefits of callbacks, validations and permission checking"
  s.license     = "LGPL-3.0"

  # s.rubyforge_project = "infopark_reactor"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "infopark_fiona_connector", "~> 7.0.1.5.2.7.rc1"
  s.add_dependency "nokogiri", "~> 1"
  s.add_dependency "rails", "~> 5.0"

  s.add_development_dependency "rspec", "~> 3"
  s.add_development_dependency "rubocop", "~> 0.89.1"
  s.add_development_dependency "rubocop-performance", "~> 1"
  s.add_development_dependency "yard", ">= 0"
end
