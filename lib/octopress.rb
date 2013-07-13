$:.unshift File.expand_path(File.dirname(__FILE__)) # For use/testing when no gem is installed

# stdlib
require 'logger'

# gems
require 'colorator'
require 'open3'
require 'stringex'
require 'time'
require 'tzinfo'
require 'safe_yaml'
require 'erb'

SafeYAML::OPTIONS[:suppress_warnings] = true

# octopress
require "octopress/version"
require "octopress/errors"
require "octopress/core_ext"
require "octopress/helpers/titlecase"

module Octopress
  autoload :Configuration,       'octopress/configuration'
  autoload :Ink,                 'octopress/ink'
  autoload :Installer,           'octopress/installer'
  autoload :Formatters,          'octopress/formatters'
  autoload :InquirableString,    'octopress/inquirable_string'
  autoload :DependencyInstaller, 'octopress/dependency_installer'
  autoload :JSAssetsManager,     'octopress/js_assets_manager'
  autoload :Command,             'octopress/command'
  autoload :Commands,            'octopress/commands'
  autoload :Rake,                'octopress/rake'
  autoload :Plugin,              'octopress/plugin'

  # Static: Get absolute file path of the octopress lib directory
  #
  # Returns the absolute path to the octopress lib directory
  def self.lib_root
    File.dirname(__FILE__)
  end

  # Static: Get absolute file path of the main octopress installation
  #
  # Returns the absolute path of the main octopress installation
  def self.root
    Dir.pwd
  end

  # Static: Fetches the Octopress environment
  #
  # Returns the Octopress environment as an InquirableString
  def self.env
    # Not simply memoizing the result in case the configuration changes out
    # from under us at runtime...  Not sure if that can happen, but just in
    # case let's be conservative in our behavior here.
    env_raw_tmp = (ENV["OCTOPRESS_ENV"] || self.configuration[:env]).to_s
    if(env_raw_tmp != @env_raw)
      @env = nil
    end
    @env_raw = env_raw_tmp
    @env ||= InquirableString.new(@env_raw)
  end

  # Static: Fetch the logger for Octopress
  #
  # Returns the Logger, based on Ruby's stdlib Logger
  def self.logger
    @@logger ||= Ink.build
  end

  def self.configurator(root_dir = Octopress::Configuration::DEFAULT_CONFIG_DIR)
    @configurator ||= Configuration.new(root_dir)
  end

  def self.configuration
    @configuration ||= self.configurator.read_configuration
  end

  def self.clear_config!
    @configurator = nil
    @configuration = nil
  end
end

def require_all(relative_path)
  Dir[File.expand_path("../#{relative_path}/**/*", __FILE__)].entries.each do |f|
    require f
  end
end

