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
    class_option :css_dir, :default => "stylesheets", :desc => 'The path to the css files'
    class_option :js_dir, :default => "javascripts", :desc => 'The path to the javascript files'
    class_option :images_dir, :default => "images", :desc => 'The path to the image files'
  end
end

# Default template
require "middleman/templates/default"
# HTML5 template
require "middleman/templates/html5"