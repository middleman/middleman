class Jeweler
  module Commands
    class CheckDependencies
      class MissingDependenciesError < RuntimeError
        attr_accessor :dependencies, :type
      end

      attr_accessor :gemspec, :type

      def run
        missing_dependencies = dependencies.select do |dependency|
          begin
            Gem.activate dependency.name, dependency.version_requirements.to_s
            false
          rescue LoadError => e
            true
          end
        end

        if missing_dependencies.empty?
          puts "#{type || 'All'} dependencies seem to be installed."
        else
          puts "Missing some dependencies. Install them with the following commands:"
          missing_dependencies.each do |dependency|
            puts %Q{\tgem install #{dependency.name} --version "#{dependency.version_requirements}"}
          end
          
          abort "Run the specified gem commands before trying to run this again: #{$0} #{ARGV.join(' ')}"
        end
        
      end

      def dependencies
        case type
        when :runtime, :development
          gemspec.send("#{type}_dependencies")
        else
          gemspec.dependencies
        end
        
      end

      def self.build_for(jeweler)
        command = new

        command.gemspec = jeweler.gemspec

        command
      end
    end
  end
end
