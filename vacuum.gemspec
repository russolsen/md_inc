# -*- encoding: utf-8 -*-
require File.expand_path('../lib/vacuum/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Russ Olsen"]
  gem.email         = ["russ@russolsen.com"]
  gem.description   = %q{Vacuum is a simple text inclusion utility (it sucks in files) intended for use with markdown and similar utilities.}
  gem.summary       = %q{A simple text inclusion utility}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "vacuum"
  gem.require_paths = ["lib"]
  gem.version       = Vacuum::VERSION
end
