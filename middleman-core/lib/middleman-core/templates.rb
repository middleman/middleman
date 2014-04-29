# Use thor for template generation
require 'thor'
require 'thor/group'

# Templates namespace
module Middleman::Templates
  # Static methods
  class << self
    # Get list of registered templates and add new ones
    #
    #     Middleman::Templates.register(:ext_name, klass)
    #
    # @param [Symbol] name The name of the template
    # @param [Class] klass The class to be executed for this template
    # @return [Hash] List of registered templates
    def register(name=nil, klass=nil)
      @_template_mappings ||= {}
      @_template_mappings[name] = klass if name && klass
      @_template_mappings
    end

    # Middleman::Templates.register(name, klass)
    alias_method :registered, :register
  end

  # Base Template class. Handles basic options and paths.
  class Base < ::Thor::Group
    include Thor::Actions

    def initialize(names, options)
      super
      source_paths << File.join(File.dirname(__FILE__), 'templates')
    end

    # The gemfile template to use. Individual templates can define this class
    # method to override the template path.
    def self.gemfile_template
      'shared/Gemfile.tt'
    end

    # Required path for the new project to be generated
    argument :location, type: :string

    # Name of the template being used to generate the project.
    class_option :template, default: 'default'

    # Output a config.ru file for Rack if --rack is passed
    class_option :rack, type: :boolean, default: false

    # Write a Rack config.ru file for project
    # @return [void]
    def generate_rack!
      return unless options[:rack]
      template 'shared/config.ru', File.join(location, 'config.ru')
    end

    class_option :'skip-bundle', type: :boolean, default: false
    class_option :'skip-gemfile', type: :boolean, default: false

    # Write a Bundler Gemfile file for project
    # @return [void]
    def generate_bundler!
      return if options[:'skip-gemfile']
      template self.class.gemfile_template, File.join(location, 'Gemfile')

      return if options[:'skip-bundle']
      inside(location) do
        ::Middleman::Cli::Bundle.new.invoke(:bundle)
      end unless ENV['TEST']
    end

    # Output a .gitignore file
    class_option :'skip-git', type: :boolean, default: false

    # Write a .gitignore file for project
    # @return [void]
    def generate_gitignore!
      return if options[:'skip-git']
      copy_file 'shared/gitignore', File.join(location, '.gitignore')
    end
  end
end

# Default template
require 'middleman-core/templates/default'

# HTML5 template
require 'middleman-core/templates/html5'

# HTML5 Mobile template
require 'middleman-core/templates/mobile'

# SMACSS templates
require 'middleman-more/templates/smacss'

# Local templates
# Sometimes HOME doesn't exist, in which case there's no point to local templates
require 'middleman-core/templates/local' if ENV['HOME']

# Barebones template
require 'middleman-core/templates/empty'
