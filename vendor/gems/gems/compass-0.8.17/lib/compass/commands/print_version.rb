module Compass
  module Commands
    class PrintVersion
      attr_accessor :options
      def initialize(working_path, options)
        self.options = options
      end
  
      def execute
        if options[:quiet]
          # The quiet option may make scripting easier
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