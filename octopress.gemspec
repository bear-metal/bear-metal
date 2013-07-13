# -*- encoding: utf-8 -*-

Gem::Specification.new do |octo|
  octo.specification_version = 2 if octo.respond_to? :specification_version=
  octo.required_rubygems_version = Gem::Requirement.new(">= 0") if octo.respond_to? :required_rubygems_version=
  octo.rubygems_version = '1.3.5'

  octo.name          = "octopress"
  octo.version       = '3.0.0.beta1'
  octo.date          = '2013-05-23'
  octo.authors       = ["Brandon Mathis", "Parker Moore"]
  octo.email         = %w[brandon@imathis.com parkrmoore@gmail.com]
  octo.description   = %q{Octopress is an obsessively designed framework for Jekyll blogging. It's easy to configure and easy to deploy. Sweet huh?}
  octo.summary       = %q{Octopress is an obsessively designed framework for Jekyll blogging.}
  octo.homepage      = "http://octopress.org"

  octo.rdoc_options = ["--charset=UTF-8"]
  octo.extra_rdoc_files = %w[README.markdown]

  # = MANIFEST =
  octo.files = %w[
    CHANGELOG.markdown
    CONTRIBUTING.markdown
    Gemfile
    README.markdown
    Rakefile
    bin/octopress
    lib/console
    lib/guard/jekyll.rb
    lib/octopress.rb
    lib/octopress/command.rb
    lib/octopress/commands.rb
    lib/octopress/commands/build.rb
    lib/octopress/commands/build_javascripts.rb
    lib/octopress/commands/build_jekyll.rb
    lib/octopress/commands/build_stylesheets.rb
    lib/octopress/commands/install.rb
    lib/octopress/commands/scaffold.rb
    lib/octopress/commands/serve.rb
    lib/octopress/configuration.rb
    lib/octopress/core_ext.rb
    lib/octopress/dependency_installer.rb
    lib/octopress/filters/content.rb
    lib/octopress/filters/date.rb
    lib/octopress/filters/post.rb
    lib/octopress/filters/url.rb
    lib/octopress/formatters.rb
    lib/octopress/formatters/base_formatter.rb
    lib/octopress/formatters/simple_formatter.rb
    lib/octopress/formatters/verbose_formatter.rb
    lib/octopress/generators/category_generator.rb
    lib/octopress/generators/sitemap_generator.rb
    lib/octopress/guardfile
    lib/octopress/helpers/titlecase.rb
    lib/octopress/ink.rb
    lib/octopress/inquirable_string.rb
    lib/octopress/installer.rb
    lib/octopress/js_asset_manager.rb
    lib/octopress/liquid_helpers/conditional.rb
    lib/octopress/liquid_helpers/config.rb
    lib/octopress/liquid_helpers/include.rb
    lib/octopress/liquid_helpers/url.rb
    lib/octopress/liquid_helpers/vars.rb
    lib/octopress/plugin.rb
    lib/octopress/rake.rb
    lib/octopress/scaffold/.gitignore
    lib/octopress/scaffold/site/config/compass.rb
    lib/octopress/scaffold/site/config/rack.rb
    lib/octopress/scaffold/site/config/site.yml
    lib/octopress/scaffold/site/javascripts/lib/ios-rotate-scaling-fix.js
    lib/octopress/scaffold/site/javascripts/lib/jquery-1.9.1.js
    lib/octopress/scaffold/site/javascripts/lib/jquery.cookie.js
    lib/octopress/scaffold/site/stylesheets/_config.scss
    lib/octopress/scaffold/site/stylesheets/_style.scss
    lib/octopress/scaffold/site/stylesheets/site.scss
    lib/octopress/tags/assign.rb
    lib/octopress/tags/capture.rb
    lib/octopress/tags/config-tag.rb
    lib/octopress/tags/include.rb
    lib/octopress/tags/js-assets.rb
    lib/octopress/tags/puts.rb
    lib/octopress/tags/render-partial.rb
    lib/octopress/tags/return.rb
    lib/rake/clean.rake
    lib/rake/clobber.rake
    lib/rake/console.rake
    lib/rake/deploy.rake
    lib/rake/gen_deploy.rake
    lib/rake/generate.rake
    lib/rake/generate_only.rake
    lib/rake/hygiene.rake
    lib/rake/install.rake
    lib/rake/integrate.rake
    lib/rake/isolate.rake
    lib/rake/list_drafts.rake
    lib/rake/new.rake
    lib/rake/new_page.rake
    lib/rake/new_post.rake
    lib/rake/nuke.rake
    lib/rake/preview.rake
    lib/rake/push.rake
    lib/rake/rsync.rake
    lib/rake/set_root_dir.rake
    lib/rake/setup_github_pages.rake
    lib/rake/watch.rake
    lib/scaffold/Rakefile
    lib/scaffold/plugin-name.gemspec
    lib/spec/fixtures/env/defaults/classic.yml
    lib/spec/fixtures/no_override/defaults/classic.yml
    lib/spec/fixtures/override/defaults/classic.yml
    lib/spec/fixtures/override/site.yml
    lib/spec/octopress/configuration_spec.rb
    lib/spec/octopress/dependency_installer_spec.rb
    lib/spec/octopress/ink_spec.rb
    lib/spec/octopress/octopress_spec.rb
    lib/spec/spec_helper.rb
    lib/spec/support/env.rb
    lib/spec/support/simplecov.rb
    octopress.gemspec
  ]
  # = MANIFEST =

  octo.require_paths = %w[lib]
  octo.executables   = octo.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  octo.test_files    = octo.files.grep(%r{^(test|spec|features)/})

  octo.add_runtime_dependency('rake', '~> 10.1.0')
  octo.add_runtime_dependency('rack', '~> 1.5.0')
  octo.add_runtime_dependency('jekyll', '~> 1.0.2')
  octo.add_runtime_dependency('redcarpet', '~> 2.2.2')
  octo.add_runtime_dependency('RedCloth', '~> 4.2.9')
  octo.add_runtime_dependency('haml', '~> 3.1.7')
  octo.add_runtime_dependency('compass', '~> 0.12.2')
  octo.add_runtime_dependency('sass-globbing', '~> 1.0.0')
  octo.add_runtime_dependency('rubypants', '~> 0.2.0')
  octo.add_runtime_dependency('stringex', '~> 1.4.0')
  octo.add_runtime_dependency('liquid', '~> 2.3.0')
  octo.add_runtime_dependency('tzinfo', '~> 0.3.35')
  octo.add_runtime_dependency('json', '~> 1.7.7')
  octo.add_runtime_dependency('sinatra', '~> 1.4.2')
  octo.add_runtime_dependency('stitch-rb', '~> 0.0.8')
  octo.add_runtime_dependency('uglifier', '~> 2.1.0')
  octo.add_runtime_dependency('guard', '~> 1.8.0')
  octo.add_runtime_dependency('guard-shell', '~> 0.5.1')
  octo.add_runtime_dependency('guard-compass', '~> 0.0.6')
  octo.add_runtime_dependency('guard-coffeescript', '~> 1.3.0')
  octo.add_runtime_dependency('rb-inotify', '~> 0.9.0')
  octo.add_runtime_dependency('rb-fsevent', '~> 0.9.3')
  octo.add_runtime_dependency('rb-fchange', '~> 0.0.6')

  octo.add_development_dependency('rspec', '~> 2.13.0')
  octo.add_development_dependency('rubocop', '~> 0.8.2')
  octo.add_development_dependency('pry', '~> 0.9.12')
end
