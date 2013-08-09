module Octopress
  class Command
    class << self
      def process(args = nil, options = nil)
        raise NotImplementedError
      end
    end
  end
end
