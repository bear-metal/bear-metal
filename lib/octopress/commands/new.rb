module Octopress
  module Commands
    class New < Command
      class << self
        def process(args = nil, options = {})
          type, argument = process_args(args)

          path = determine_path(type, argument)
          title = determine_title(type, argument)

          new_thing(type, path, title, options)
        end

        def process_args(args)
          if args.nil? || args.empty?
            Octopress.logger.error "No type or directory specified. Try 'octopress help new' for help."
            raise ArgumentError
          end

          if args.size == 1
            ["site", args.first]
          else
            if %w[page post link_post].include?(args.first.to_s.downcase)
              [args.first.to_s.downcase, args[1].to_s]
            else
              Octopress.logger.error("Sorry, we could not create a new '#{args[1].to_s}'.")
              raise ArgumentError
            end
          end
        end

        def new_site(destination, options)
          source = File.join(Octopress.lib_root, 'octopress/scaffold/site')
          FileUtils.cp_r "#{source}/.", "#{destination}/"
        end

        def determine_path(type, argument)
          case type
          when "page"
            argument
          else
            argument.gsub(/[^a-zA-Z0-9]/, '-').
              gsub(/-+/, '-').
              gsub(/(^-|-$)/, '').
              downcase
          end
        end

        def determine_title(type, argument)
          case type
          when "page"
            argument.
              split(".")[0..-2].join("."). #remove extname
              split("/").map do |piece|
                piece.gsub(/[^a-zA-Z0-9.]/, ' ').capitalize
              end.join(" - ")
          else
            argument
          end
        end

        def new_thing(type, path, title, options)
          template = if options.has_key?("template")
            File.join("templates/#{options["template"]}")
          else
            template_file(type)
          end

          date = if options.has_key?("date")
            Time.parse(options["date"])
          else
            Time.now
          end

          if type.include?("post")
            path = "_posts/#{date.strftime('%Y-%m-%d')}-#{path}.markdown"
          end
          path = "#{Octopress.configuration[:source]}/#{path}"

          FileUtils.mkdir_p(File.dirname(path))
          File.open(path, "wb") do |f|
            f.puts ERB.new(File.read(template)).result(binding)
          end
        end

        def template_file(type)
          File.join(Octopress.lib_root, 'octopress/scaffold/templates', "#{type}.markdown.erb")
        end
      end
    end
  end
end
