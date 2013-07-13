desc "Open Octopress console"
task :console do
  prompt = `which pry`.strip.empty? ? "irb" : "pry"
  sh "#{prompt} -r./lib/octopress.rb", verbose: false
end
