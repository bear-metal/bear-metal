# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'octopress/version'

Gem::Specification.new do |spec|
  spec.name          = "octopress"
  spec.version       = Octopress::VERSION
  spec.authors       = ["Brandon Mathis", "Parker Moore"]
  spec.email         = ["brandon@imathis.com", "parkrmoore@gmail.com"]
  spec.description   = "Octopress is an obsessively designed framework for Jekyll blogging. It's easy to configure and easy to deploy. Sweet huh?"
  spec.summary       = "Octopress is an obsessively designed framework for Jekyll blogging."
  spec.homepage      = "http://octopress.org"
  spec.license       = "MIT"

  spec.rdoc_options = ["--charset=UTF-8"]
  spec.extra_rdoc_files = %w[README.markdown CHANGELOG.markdown]

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency('rake', '~> 10.1.0')
  spec.add_runtime_dependency('rack', '~> 1.5.0')
  spec.add_runtime_dependency('jekyll', '~> 1.0.2')
  spec.add_runtime_dependency('redcarpet', '~> 2.2.2')
  spec.add_runtime_dependency('RedCloth', '~> 4.2.9')
  spec.add_runtime_dependency('haml', '~> 3.1.7')
  spec.add_runtime_dependency('compass', '~> 0.12.2')
  spec.add_runtime_dependency('sass-globbing', '~> 1.1.0')
  spec.add_runtime_dependency('rubypants', '~> 0.2.0')
  spec.add_runtime_dependency('stringex', '~> 1.4.0')
  spec.add_runtime_dependency('liquid', '~> 2.3.0')
  spec.add_runtime_dependency('tzinfo', '~> 0.3.35')
  spec.add_runtime_dependency('json', '~> 1.7.7')
  spec.add_runtime_dependency('sinatra', '~> 1.4.2')
  spec.add_runtime_dependency('stitch-rb', '~> 0.0.8')
  spec.add_runtime_dependency('uglifier', '~> 2.1.0')
  spec.add_runtime_dependency('guard', '~> 1.8.0')
  spec.add_runtime_dependency('guard-shell', '~> 0.5.1')
  spec.add_runtime_dependency('guard-compass', '~> 0.0.6')
  spec.add_runtime_dependency('guard-coffeescript', '~> 1.3.0')
  spec.add_runtime_dependency('rb-inotify', '~> 0.9.0')
  spec.add_runtime_dependency('rb-fsevent', '~> 0.9.3')
  spec.add_runtime_dependency('rb-fchange', '~> 0.0.6')

  spec.add_development_dependency('bundler', '~> 1.3')
  spec.add_development_dependency('rspec', '~> 2.13.0')
  spec.add_development_dependency('rubocop', '~> 0.8.2')
  spec.add_development_dependency('pry', '~> 0.9.12')
end
