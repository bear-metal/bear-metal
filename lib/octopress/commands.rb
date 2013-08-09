$:.unshift(File.dirname(__FILE__))

module Octopress
  module Commands
    autoload :Build,            'commands/build'
    autoload :BuildJekyll,      'commands/build_jekyll'
    autoload :BuildJavascripts, 'commands/build_javascripts'
    autoload :BuildStylesheets, 'commands/build_stylesheets'
    autoload :Install,          'commands/install'
    autoload :New,              'commands/new'
    autoload :Scaffold,         'commands/scaffold'
    autoload :Serve,            'commands/serve'
  end
end
