# -*- encoding: utf-8 -*-
require File.expand_path('../lib/steno/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["mpage"]
  gem.email         = ["mpage@rbcon.com"]
  gem.description   = "A thread-safe logging library designed to support" \
                      + " multiple log destinations."
  gem.summary       = "A logging library."
  gem.homepage      = "http://www.cloudfoundry.org"

  gitignore = File.readlines(".gitignore").grep(/^[^#]/).map { |s| s.chomp }

  # Ignore Gemfile, this is a library
  gitignore << "Gemfile*"

  glob = Dir["**/*"].
    reject { |f| File.directory?(f) }.
    reject { |f| gitignore.any? { |i| File.fnmatch(i, f) } }

  gem.files         = glob
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "steno"
  gem.require_paths = ["lib"]
  gem.version       = Steno::VERSION

  gem.add_dependency("grape")
  gem.add_dependency("yajl-ruby", "~> 1.0")
  gem.add_dependency("fluent-logger")
  
  gem.add_development_dependency("ci_reporter")
  gem.add_development_dependency("rack-test")
  gem.add_development_dependency("rake")
  gem.add_development_dependency("rspec")
  
  if RUBY_PLATFORM=~ /mswin|mingw|cygwin/
    gem.platform      = Gem::Platform::CURRENT
    gem.add_dependency("win32-eventlog")
  end
end
