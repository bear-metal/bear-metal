module Octopress
  module Commands
    class Serve < Command
      class << self
        def process(args, options)
          Octopress::Commands::Build.process(args, options)
          serve(args, options)
        end

        def serve(args, options)
          guardPid = Process.spawn("guard --guardfile #{Octopress.lib_root}/octopress/guardfile")
          puts "Starting Rack, serving to http://#{Octopress.configuration[:server_host]}:#{Octopress.configuration[:port]}"
          rackupPid = Process.spawn("rackup --host #{Octopress.configuration[:server_host]} --port #{Octopress.configuration[:port]}")

          trap("INT") {
            [guardPid, rackupPid].each { |pid| Process.kill(3, pid) rescue Errno::ESRCH }
            exit 0
          }

          [guardPid, rackupPid].each { |pid| Process.wait(pid) }
        end
      end
    end
  end
end
