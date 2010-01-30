module Compass::Exec
  class CommandOptionParser
    attr_accessor :options, :arguments, :opts
    def initialize(arguments)
      self.arguments = arguments
      self.options = {}
    end
    def parse!
      opts.parse!(arguments)
    end
    def opts
      OptionParser.new do |opts|
        self.set_options(opts)
      end
    end
    def set_options(opts)

    end
    def to_s
      opts.to_s
    end
  end
end
