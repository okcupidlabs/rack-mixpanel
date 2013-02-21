# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "rack-mixpanel"
  gem.version       = "0.1.0"
  gem.authors       = ["Derek Barnes"]
  gem.email         = ["barnes@okcupidlabs.com"]
  gem.description   = %q{Rack middleware for tracking Mixpanel events}
  gem.summary       = %q{Rack middleware for tracking Mixpanel events}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'rack'
  gem.add_development_dependency 'fakeweb'
  gem.add_development_dependency 'rspec'
end
