class Jeweler
  module Commands
    class WriteGemspec
      attr_accessor :base_dir, :gemspec, :version, :output, :gemspec_helper, :version_helper

      def initialize
        self.output = $stdout
      end

      def run
        gemspec_helper.spec.version ||= begin
          version_helper.refresh
          version_helper.to_s
        end

        gemspec_helper.spec.date    = Time.now
        gemspec_helper.write

        output.puts "Generated: #{gemspec_helper.path}"  
      end

      def gemspec_helper
        @gemspec_helper ||= GemSpecHelper.new(self.gemspec, self.base_dir)
      end

      def self.build_for(jeweler)
        command = new

        command.base_dir = jeweler.base_dir
        command.gemspec = jeweler.gemspec
        command.version = jeweler.version
        command.output = jeweler.output
        command.gemspec_helper = jeweler.gemspec_helper
        command.version_helper = jeweler.version_helper

        command
      end

    end
  end
end
