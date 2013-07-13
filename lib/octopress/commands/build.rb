module Octopress
  module Commands
    class Build < Command
      class << self
        def process(args, options)
          if Octopress.configuration[:source].nil? || !File.directory?(Octopress.configuration[:source])
            Octopress.logger.error "### You haven't set anything up yet. First run `octopress install <theme-name>` to set up an Octopress theme."
            raise SiteNotFoundError
          end
          BuildJavascripts.process(args, options)
          BuildStylesheets.process(args, options)
          BuildJekyll.process(args, options)
        end
      end
    end
  end
end
