module Octopress
  module Commands
    class BuildJekyll < Command
      class << self
        def process(args, options)
          Octopress.configurator.write_configs_for_generation
          puts "## Generating Site with Jekyll - ENV: #{Octopress.env}"
          system "jekyll build #{jekyll_flags}"
          puts unpublished unless unpublished.empty?
          Octopress.configurator.remove_configs_for_generation
        end

        def unpublished
          posts   = Dir.glob("#{Octopress.configuration[:source]}/#{Octopress.configuration[:posts_dir]}/*.*")
          options = {env: Octopress.env, message: "\nThese posts were not generated:"}
          @unpublished ||= get_unpublished(posts, options)
        end

        def jekyll_flags
          Octopress.env.production? ? "" : "--drafts --trace"
        end

        def get_unpublished(posts, options = {})
          result = ""
          message = options[:message] || "These Posts will not be published:"
          posts.sort.each do |post|
            file = File.read(post)
            data = YAML.load file.match(/(^-{3}\n)(.+?)(\n-{3})/m)[2]

            if options[:env] == 'production'
              future = Time.now < Time.parse(data['date'].to_s) ? "future date: #{data['date']}" : false
            end
            draft = data['published'] == false ? 'published: false' : false
            result << "- #{data['title']} (#{draft or future})\n" if draft or future
          end
          result = "#{message}\n" + result unless result.empty?
          result
        end
      end
    end
  end
end
