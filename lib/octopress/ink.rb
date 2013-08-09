require 'logger'

module Octopress
  class Ink < Logger
    def self.build
      logger = Logger.new(STDOUT)
      logger.level = Logger::INFO
      logger.formatter = Formatters::BaseFormatter.new
      logger
    end
  end
end
