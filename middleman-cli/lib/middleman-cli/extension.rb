# CLI Module
module Middleman::Cli
  # A thor task for creating new projects
  class Extension < Thor::Group
    include Thor::Actions

    check_unknown_options!

    # Required path for the new project to be generated
    argument :name, type: :string

    # Template files are relative to this file
    # @return [String]
    def self.source_root
      File.join(File.dirname(__FILE__), 'templates')
    end

    class_option 'skip-git',
                 type: :boolean,
                 default: false,
                 desc: 'Skip Git ignores and keeps'

    # Output a .gitignore file
    class_option :git, type: :boolean, default: true

    # The extension task
    # @param [String] name
    def extension
      copy_file 'extension/gitignore', File.join(name, '.gitignore') unless options[:'skip-git']
      template 'extension/Rakefile', File.join(name, 'Rakefile')
      template 'extension/gemspec', File.join(name, "#{name}.gemspec")
      template 'extension/Gemfile', File.join(name, 'Gemfile')
      template 'extension/lib/lib.rb', File.join(name, 'lib', "#{name}.rb")
      template 'extension/lib/lib/extension.rb', File.join(name, 'lib', name, 'extension.rb')
      template 'extension/features/support/env.rb', File.join(name, 'features', 'support', 'env.rb')
      empty_directory File.join(name, 'fixtures')
    end

    # Add to CLI
    Base.register(self, 'extension', 'extension [options]', 'Create a new Middleman extension')
  end
end
