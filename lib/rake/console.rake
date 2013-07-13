desc "Open Octopress console"
task :console do
  sh "irb -r./lib/octopress.rb"
end
