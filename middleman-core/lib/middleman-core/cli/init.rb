# CLI Module
module Middleman::Cli
  
  # A thor task for creating new projects
  class Init < Thor
    check_unknown_options!
    
    namespace :init
    
    desc "init NAME [options]", "Create new project NAME"
    available_templates = ::Middleman::Templates.registered.keys.join(", ")
    method_option "template", 
      :aliases => "-T", 
      :default => "default",
      :desc    => "Use a project template: #{available_templates}"
    method_option "css_dir", 
      # :default => "stylesheets", 
      :desc    => 'The path to the css files'
    method_option "js_dir", 
      # :default => "javascripts", 
      :desc    => 'The path to the javascript files'
    method_option "images_dir", 
      # :default => "images", 
      :desc    => 'The path to the image files'
    method_option "rack", 
      :type    => :boolean, 
      :default => false, 
      :desc    => 'Include a config.ru file'
    method_option "bundler", 
      :type    => :boolean, 
      :default => false, 
      :desc    => 'Create a Gemfile and use Bundler to manage gems'
    # The init task
    # @param [String] name
    def init(name)
      key = options[:template].to_sym
      unless ::Middleman::Templates.registered.has_key?(key)
        raise Thor::Error.new "Unknown project template '#{key}'"
      end
      
      thor_group = ::Middleman::Templates.registered[key]
      thor_group.new([name], options).invoke_all
    end
  end

  def self.exit_on_failure?
    true
  end
  
  # Map "i", "new" and "n" to "init"
  Base.map({
    "i"   => "init",
    "new" => "init",
    "n"   => "init"
  })
end
