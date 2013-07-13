task :install, :plugin do |t, args|
  plugin = args.plugin
  if plugin.nil? || plugin == ""
    plugin = "classic-theme"
  end
  Octopress::DependencyInstaller.install_all(plugin)
end
