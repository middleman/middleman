class Jeweler
  module Commands
    class SetupRubyforge
      attr_accessor :gemspec, :output, :rubyforge


      def initialize
        self.output = $stdout
        require 'rubyforge'
        self.rubyforge = RubyForge.new
      end

      def run
        raise NoRubyForgeProjectInGemspecError unless @gemspec.rubyforge_project

        @rubyforge.configure

        output.puts "Logging into rubyforge"
        @rubyforge.login

        if package_exists?
          output.puts "#{@gemspec.name} package already exists in the #{@gemspec.rubyforge_project} project"
          return
        end

        output.puts "Creating #{@gemspec.name} package in the #{@gemspec.rubyforge_project} project"
        create_package
      end

      def package_exists?
        begin
          @rubyforge.lookup 'package', @gemspec.name
          true
        rescue RuntimeError => e
          raise unless e.message == "no <package_id> configured for <#{@gemspec.name}>"
          false
        end
      end

      def create_package
        begin
          @rubyforge.create_package(@gemspec.rubyforge_project, @gemspec.name)
        rescue StandardError => e
          case e.message
          when /no <group_id> configured for <#{Regexp.escape @gemspec.rubyforge_project}>/
            raise RubyForgeProjectNotConfiguredError, @gemspec.rubyforge_project
          else
            raise
          end
        end
      end

      def self.build_for(jeweler)
        command = new

        command.gemspec = jeweler.gemspec
        command.output = jeweler.output

        command
      end
    end
  end
end
