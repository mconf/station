$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "station"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Station"
  s.email       = "mconf-dev@googlegroups.com"
  s.homepage    = "http://github.com/mconf/station"
  s.description = "Station"
  s.authors     = []

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_dependency("rails", ">= 3.0.0")
end
