class Jeweler
  module Commands
    class ReleaseToGemcutter
      attr_accessor :gemspec, :version, :output, :gemspec_helper

      def initialize
        self.output = $stdout
      end

      def run
        command = "gem push #{@gemspec_helper.gem_path}"
        output.puts "Executing #{command.inspect}:"
        sh command
      end

      def self.build_for(jeweler)
        command = new
        command.gemspec        = jeweler.gemspec
        command.gemspec_helper = jeweler.gemspec_helper
        command.version        = jeweler.version
        command.output         = jeweler.output
        command
      end
      
    end
  end
end
