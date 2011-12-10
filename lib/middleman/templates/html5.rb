# HTML5 Boilerplate template
class Middleman::Templates::Html5 < Middleman::Templates::Base
  
  # Has different default paths
  class_option :css_dir, :default => "css"
  class_option :js_dir, :default => "js"
  class_option :images_dir, :default => "img"

  # Templates are relative to this file
  def self.source_root
    File.dirname(__FILE__)
  end
  
  # Output the files
  def build_scaffold
    template "shared/config.tt", File.join(location, "config.rb")
    directory "html5/source", File.join(location, "source")
    empty_directory File.join(location, "source")
  end
end

# Register the template
Middleman::Templates.register(:html5, Middleman::Templates::Html5)