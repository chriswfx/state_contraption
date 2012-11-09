# -*- encoding: utf-8 -*-
require File.expand_path('../lib/state_contraption/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Chris Williams"]
  gem.email         = ["chris@wellnessfx.com"]
  gem.description   = %q{This gem facilitates a particular pattern for simple state machines that I happen to like.}
  gem.summary       = %q{A lightweight state machine gem for ActiveRecord}
  gem.homepage      = "https://github.com/chriswfx/state_contraption"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "state_contraption"
  gem.require_paths = ["lib"]
  gem.version       = StateContraption::VERSION

  gem.add_runtime_dependency 'activesupport', '>= 3'

  gem.add_development_dependency 'rspec', '~> 2.11'
  gem.add_development_dependency 'activerecord', '>= 3'
  gem.add_development_dependency 'sqlite3'
end
