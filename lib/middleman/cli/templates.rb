module Middleman::CLI
  class Templates < Thor::Group
    check_unknown_options!
    
    desc "init NAME [options]"
    available_templates = ::Middleman::Templates.registered.keys.join(", ")
    argument :name
    class_option "template", 
      :aliases => "-T", 
      :default => "default",
      :desc    => "Use a project template: #{available_templates}"
    class_option "css_dir", 
      :default => "stylesheets", 
      :desc    => 'The path to the css files'
    class_option "js_dir", 
      :default => "javascripts", 
      :desc    => 'The path to the javascript files'
    class_option "images_dir", 
      :default => "images", 
      :desc    => 'The path to the image files'
    class_option "rack", 
      :type    => :boolean, 
      :default => false, 
      :desc    => 'Include a config.ru file'
    class_option "bundler", 
      :type    => :boolean, 
      :default => false, 
      :desc    => 'Create a Gemfile and use Bundler to manage gems'
    def init
      key = options[:template].to_sym
      unless ::Middleman::Templates.registered.has_key?(key)
        raise Thor::Error.new "Unknown project template '#{key}'"
      end
      
      thor_group = ::Middleman::Templates.registered[key]
      thor_group.new([name], options).invoke_all
    end
  end
  
  Base.register(Templates, :init, "init NAME [options]", "Create new project NAME")
  Base.map({
    "i"   => "init",
    "new" => "init",
    "n"   => "init"
  })
end