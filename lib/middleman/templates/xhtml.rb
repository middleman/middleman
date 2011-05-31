class Middleman::Templates::Xhtml < Middleman::Templates::Base
  def self.source_root
    File.join(File.dirname(__FILE__), 'default')
  end
  
  def build_scaffold
    template "config.tt", File.join(location, "config.rb")
    template "config.ru", File.join(location, "config.ru")
    directory "source", File.join(location, "source")
    empty_directory File.join(location, "source", options[:css_dir])
    empty_directory File.join(location, "source", options[:js_dir])
    empty_directory File.join(location, "source", options[:images_dir])
  end  
end

Middleman::Templates.register(:xhtml, Middleman::Templates::Xhtml)