desc "preview the site in a web browser."
task :preview do
  Octopress::Commands::Serve.process([], {})
end
