class Jeweler
  module Commands
    class ReleaseToRubyforge
      attr_accessor :gemspec, :version, :output, :gemspec_helper, :rubyforge

      def initialize
        self.output = $stdout

        require 'rubyforge'
        self.rubyforge = RubyForge.new
      end

      def run

        raise NoRubyForgeProjectInGemspecError unless @gemspec.rubyforge_project
        
        @rubyforge.configure rescue nil

        output.puts 'Logging in rubyforge'
        @rubyforge.login

        @rubyforge.userconfig['release_notes'] = @gemspec.description if @gemspec.description
        @rubyforge.userconfig['preformatted'] = true

        output.puts "Releasing #{@gemspec.name}-#{@version} to #{@gemspec.rubyforge_project}"
        begin
          @rubyforge.add_release(@gemspec.rubyforge_project, @gemspec.name, @version.to_s, @gemspec_helper.gem_path)
        rescue StandardError => e
          case e.message
          when /no <group_id> configured for <#{Regexp.escape @gemspec.rubyforge_project}>/
            raise RubyForgeProjectNotConfiguredError, @gemspec.rubyforge_project
          when /no <package_id> configured for <#{Regexp.escape @gemspec.name}>/i
            raise MissingRubyForgePackageError, @gemspec.name
          else
            raise
          end
        end
      end

      def self.build_for(jeweler)
        command = new
        command.gemspec = jeweler.gemspec
        command.gemspec_helper = jeweler.gemspec_helper
        command.version = jeweler.version
        command.output = jeweler.output

        command
      end
      
    end
  end
end
