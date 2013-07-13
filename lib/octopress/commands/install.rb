module Octopress
  module Commands
    class Install < Command
      class << self
        def process(args = nil, options = nil)
          raise "Please specify at least one plugin to install." if args.nil? || args.empty?

          plugin_name = args[0]
          require_plugin(plugin_name)

          # Essentially doing: 'Adn::Installer.new.install':
          Object.const_get(classify(plugin_name))::Installer.new.install
        end

        def require_plugin(plugin_name)
          require "#{plugin_name}"
        rescue LoadError
          begin
            if File.read("#{Octopress.root}/Gemfile").match(/gem ["']#{plugin_name}["']/)
              Octopress.logger.warn("Oops! Looks like you haven't installed the gem but you have it in your Gemfile. Running 'bundle install'...")
              `bundle install`
              require "#{plugin_name}"
            else
              raise LoadError, "Cannot load #{plugin_name}"
            end
          rescue LoadError
            Octopress.logger.error("We could couldn't find the plugin '#{plugin_name}'.")
            Octopress.logger.error("Make sure you add this to your Gemfile:\n")
            Octopress.logger.error("gem '#{plugin_name}'\n")
            Octopress.logger.error("Then run 'bundle install' and retry the installation.")
            raise LoadError, "Cannot load #{plugin_name}"
          end
        end

        def classify(plugin_name)
          rubyify(plugin_name).split("_").map(&:capitalize).join("")
        end

        def rubyify(plugin_name)
          plugin_name.to_s.gsub(/-/, '_')
        end
      end
    end
  end
end
