$:.unshift(File.dirname(__FILE__))

module Octopress
  module Formatters
    autoload :BaseFormatter,    'formatters/base_formatter'
    autoload :SimpleFormatter,  'formatters/simple_formatter'
    autoload :VerboseFormatter, 'formatters/verbose_formatter'
  end
end
