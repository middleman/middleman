require "thor"
require "thor/group"

module Middleman::Templates
  @@template_mappings = {}
  def self.register(name, klass)
    @@template_mappings[name] = klass
  end
  
  def self.registered_names
    @@template_mappings.keys
  end
  
  def self.registered_templates
    @@template_mappings
  end
  
  class Base < ::Thor::Group
    include Thor::Actions
    
    argument :location, :type => :string
    class_option :template, :default => "default"
    class_option :css_dir, :default => "stylesheets"
    class_option :js_dir, :default => "javascripts"
    class_option :images_dir, :default => "images"
  end
end

# Default template
require "middleman/templates/default"

# HTML5 template
require "middleman/templates/html5"

# Local templates
require "middleman/templates/local"

# Compass templates
# require "middleman/templates/compass"