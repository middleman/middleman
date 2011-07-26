class Middleman::Templates::Blog < Middleman::Templates::Base
  def self.source_root
    File.dirname(__FILE__)
  end
  
  def build_scaffold
    template "blog/config.tt", File.join(location, "config.rb")
    template "blog/config.ru", File.join(location, "config.ru")
    directory "blog/source", File.join(location, "source")
    
    empty_directory File.join(location, "source", options[:css_dir])
    empty_directory File.join(location, "source", options[:js_dir])
    empty_directory File.join(location, "source", options[:images_dir])
  end
end

Middleman::Templates.register(:blog, Middleman::Templates::Blog)