# encoding: utf-8

$:.unshift File.expand_path("lib", File.dirname(__FILE__)) # For use/testing when no gem is installed
require 'octopress'
require 'tzinfo'

### Configuring Octopress:
###   Under config/ you will find:
###       site.yml, deploy.yml
###   Here you can override Octopress's default configurations or add your own.
###   This Rakefile uses those config settings to do what it does.
###   Please do not change anything below if you want help --
###   otherwise, you're on your own ;-)

#
# Run tests for Octopress module, found in lib/.
#
require 'rspec/core/rake_task'
desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "./spec{,/*/**}/*_spec.rb"
end

task :test do
  sh "bundle exec rake spec"
  #sh "bundle exec rake install['classic-theme']"
  #sh "bundle exec rake install['video-tag']"
  #sh "bundle exec rake install['adn-timeline']"
  #sh "bundle exec rake generate"
end

