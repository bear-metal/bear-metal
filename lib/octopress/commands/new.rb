module Octopress
  module Commands
    class New < Command
      class << self
        def process(args = nil, options = nil)
          source = File.join(Octopress.root, 'lib/octopress/scaffold/site')
          destination = process_args(args)
          FileUtils.cp_r "#{source}/.", "#{destination}/"
        end

        def process_args(args)
          if args.nil? || args.empty?
            Octopress.logger.error "You must specify a destination for your new site."
            raise ArgumentError
          end
          args.first
        end
      end
    end
  end
end
