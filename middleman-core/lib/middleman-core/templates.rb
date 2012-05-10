# Use thor for template generation
require "thor"
require "thor/group"

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
    alias :registered :register
  end
  
  # Base Template class. Handles basic options and paths.
  class Base < ::Thor::Group
    include Thor::Actions
    
    def initialize(names, options)
      super
      source_paths << File.join(File.dirname(__FILE__), 'templates')
    end

    # Required path for the new project to be generated
    argument :location, :type => :string
    
    # Name of the template being used to generate the project.
    class_option :template, :default => "default"
    
    # Output a config.ru file for Rack if --rack is passed
    class_option :rack, :type => :boolean, :default => false
    
    # Write a Rack config.ru file for project
    # @return [void]
    def generate_rack!
      return unless options[:rack]
      template "shared/config.ru", File.join(location, "config.ru")
    end
    
    # Write a Bundler Gemfile file for project
    # @return [void]
    def generate_bundler!
      template "shared/Gemfile.tt", File.join(location, "Gemfile")
      
      inside(location) do
        ::Middleman::Cli::Bundle.new.invoke(:bundle)
      end unless ENV["TEST"]
    end

    # Output a .gitignore file
    class_option :git, :type => :boolean, :default => true
    
    # Write a .gitignore file for project
    # @return [void]
    def generate_gitignore!
      return unless options[:git]
      copy_file "shared/gitignore", File.join(location, ".gitignore")
    end
  end
end

# Default template
require "middleman-core/templates/default"

# HTML5 template
require "middleman-core/templates/html5"

# HTML5 Mobile template
require "middleman-core/templates/mobile"

# Local templates
require "middleman-core/templates/local"
