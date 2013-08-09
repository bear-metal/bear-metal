# -*- encoding: utf-8 -*-

require "safe_yaml"

def manifest
  @manifest ||= YAML.safe_load_file(File.expand_path("../MANIFEST.yml", __FILE__))
end

Gem::Specification.new do |plugin|
  plugin.specification_version = 2 if plugin.respond_to? :specification_version=
  plugin.required_rubygems_version = Gem::Requirement.new(">= 0") if plugin.respond_to? :required_rubygems_version=
  plugin.rubygems_version = '1.3.5'

  plugin.name          = manifest["name"]
  plugin.version       = manifest["version"]
  plugin.date          = '2013-05-23'
  plugin.authors       = manifest["authors"]
  plugin.email         = manifest["emails"]
  plugin.description   = manifest["description"]
  plugin.summary       = manifest["summary"]
  plugin.homepage      = manifest["homepage"]

  plugin.rdoc_options = ["--charset=UTF-8"]
  plugin.extra_rdoc_files = manifest["extra_rdoc_files"]

  # = MANIFEST =
  plugin.files = %w[
  ]
  # = MANIFEST =

  plugin.require_paths = %w[lib]
  plugin.executables   = plugin.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  plugin.test_files    = plugin.files.grep(%r{^(test|spec|features)/})

  {
    "octopress" => "~> 3.0.0"
  }.each do |gem_name, version|
    plugin.add_runtime_dependency(gem_name, version)
  end

  plugin.add_development_dependency('rake', '~> 10.0.3')
  plugin.add_development_dependency('rspec', '~> 2.13.0')
end
