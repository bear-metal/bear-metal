module Octopress
  module Formatters
    class BaseFormatter < Logger::Formatter

      COLORS = {
        "ERROR" => "red",
        "WARN"  => "yellow",
        "INFO"  => "green",
        "DEBUG" => "white"
      }

      def call(severity, timestamp, progname, msg)
        (progname || msg).to_s.send(COLORS[severity]) + "\n"
      end
    end
  end
end
