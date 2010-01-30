module Compass
  module Commands
    module VersionOptionsParser
      def set_options(opts)
        opts.banner = %Q{Usage: compass version [options]

Options:
}
        opts.on_tail("-?", "-h", "--help", "Print out this message.") do
          puts opts
          exit
        end
        opts.on("-q", "--quiet", "Just print the version string.") do
          self.options[:quiet] = true
        end
        opts.on("--major", "Print the major version number") do
          self.options[:major] = true
          self.options[:custom] = true
        end
        opts.on("--minor", "Print up to the minor version number") do
          self.options[:major] = true
          self.options[:minor] = true
          self.options[:custom] = true
        end
        opts.on("--patch", "Print up to the patch version number") do
          self.options[:major] = true
          self.options[:minor] = true
          self.options[:patch] = true
          self.options[:custom] = true
        end
        opts.on("--revision", "Include the source control revision") do
          self.options[:revision] = true
          self.options[:custom] = true
        end
      end
    end

    class PrintVersion < Base
      register :version

      class << self
        def option_parser(arguments)
          parser = Compass::Exec::CommandOptionParser.new(arguments)
          parser.extend(VersionOptionsParser)
        end
        def usage
          option_parser([]).to_s
        end
        def description(command)
          "Print out version information"
        end
        def parse!(arguments)
          parser = option_parser(arguments)
          parser.parse!
          parser.options
        end
      end

      attr_accessor :options

      def initialize(working_path, options)
        self.options = options
      end
  
      def execute
        if options[:custom]
          version = ""
          version << "#{Compass.version[:major]}" if options[:major]
          version << ".#{Compass.version[:minor]}" if options[:minor]
          version << ".#{Compass.version[:teeny]}" if options[:patch]
          if options[:revision]
            if version.size > 0
              version << " [#{Compass.version[:rev][0..6]}]"
            else
              version << Compass.version[:rev]
            end
          end
          puts version
        elsif options[:quiet]
          puts ::Compass.version[:string]
        else
          lines = []
          lines << "Compass #{::Compass.version[:string]}"
          lines << "Copyright (c) 2008-2009 Chris Eppstein"
          lines << "Released under the MIT License."
          puts lines.join("\n")
        end
      end
    end
  end
end
