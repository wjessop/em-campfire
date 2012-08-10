# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "em-campfire/version"

Gem::Specification.new do |s|
  s.name        = "em-campfire"
  s.version     = EventMachine::Campfire::VERSION
  s.authors     = ["Will Jessop"]
  s.email       = ["will@willj.net"]
  s.homepage    = "https://github.com/wjessop/em-campfire"
  s.summary     = %q{Eventmachine campfire API lib}
  s.description = %q{Eventmachine campfire API lib}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency('eventmachine', '~> 1.0.0.rc.4')
  s.add_dependency('yajl-ruby', '~> 1.1')
  s.add_dependency('em-http-request', '~> 1.0.0.beta.4')

  s.add_development_dependency "rake", "~> 0.9.2"
  s.add_development_dependency "rspec", "~> 2.6.0"
  s.add_development_dependency "mocha"
  s.add_development_dependency "webmock"
  s.add_development_dependency "simplecov"
end
