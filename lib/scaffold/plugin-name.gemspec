# -*- encoding: utf-8 -*-

require "safe_yaml"

def manifest
  @manifest ||= YAML.safe_load_file(File.expand_path("../MANIFEST.yml", __FILE__))
end

Gem::Specification.new do |g|
  g.specification_version = 2 if g.respond_to? :specification_version=
  g.required_rubygems_version = Gem::Requirement.new(">= 0") if g.respond_to? :required_rubygems_version=
  g.rubygems_version = '1.3.5'

  g.name          = manifest["name"]
  g.version       = manifest["version"]
  g.date          = '2013-05-23'
  g.authors       = manifest["authors"]
  g.email         = manifest["emails"]
  g.description   = manifest["description"]
  g.summary       = manifest["summary"]
  g.homepage      = manifest["homepage"]

  g.rdoc_options = ["--charset=UTF-8"]
  g.extra_rdoc_files = manifest["extra_rdoc_files"]

  # = MANIFEST =
  g.files = %w[
  ]
  # = MANIFEST =

  g.require_paths = %w[lib]
  g.executables   = g.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  g.test_files    = g.files.grep(%r{^(test|spec|features)/})

  {
    "octopress" => "~> 3.0.0"
  }.each do |gem_name, version|
    g.add_runtime_dependency(gem_name, version)
  end

  g.add_development_dependency('rake', '~> 10.0.3')
  g.add_development_dependency('rspec', '~> 2.13.0')
end
