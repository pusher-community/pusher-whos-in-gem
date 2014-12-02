# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'whos_in/version'

Gem::Specification.new do |spec|
  spec.name          = "pusher-whos-in"
  spec.version       = WhosIn::VERSION
  spec.authors       = ["Jamie Patel"]
  spec.email         = ["jamie@notespublication.com"]
  spec.summary       = %q{Sets up and deploys your own Who's In application}
  spec.description   = %q{Sets up heroku deployment, config variables and the script that scans the local network and posts to your app}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = ["pusher-whos-in", "local_scanner"]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency "commander", ">= 4.2.1"
  spec.add_runtime_dependency "rufus-scheduler", "~> 3.0"
  spec.add_runtime_dependency "system-getifaddrs", "~> 0.2"
end
