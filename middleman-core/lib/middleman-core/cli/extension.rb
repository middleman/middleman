# CLI Module
module Middleman::Cli
  # A thor task for creating new projects
  class Extension < Thor
    include Thor::Actions

    check_unknown_options!

    namespace :extension

    # Required path for the new project to be generated
    argument :name, type: :string

    # Template files are relative to this file
    # @return [String]
    def self.source_root
      File.join(File.dirname(__FILE__), '..', 'templates', 'extension')
    end

    desc 'extension [options]', 'Create Middleman extension scaffold NAME'

    # The extension task
    # @param [String] name
    def extension
      generate_gitignore!
      template 'Rakefile', File.join(name, 'Rakefile')
      template 'gemspec', File.join(name, "#{name}.gemspec")
      template 'Gemfile', File.join(name, 'Gemfile')
      template 'lib/middleman_extension.rb', File.join(name, 'lib', 'middleman_extension.rb')
      template 'lib/lib.rb', File.join(name, 'lib', "#{name}.rb")
      template 'features/support/env.rb', File.join(name, 'features', 'support', 'env.rb')
      empty_directory File.join(name, 'fixtures')
    end

    # Output a .gitignore file
    class_option :git, type: :boolean, default: true

    no_tasks {
      # Write a .gitignore file for project
      # @return [void]
      def generate_gitignore!
        return unless options[:git]
        copy_file 'gitignore', File.join(name, '.gitignore')
      end
    }
  end
end
