class Middleman::Templates::Xhtml < Middleman::Templates::Base
  def self.source_root
    File.join(File.dirname(__FILE__), 'default')
  end
  
  def build_scaffold
    template "config.tt", File.join(location, "config.rb")
    template "config.ru", File.join(location, "config.ru")
    directory "views", File.join(location, "views")
    empty_directory File.join(location, "public", options[:css_dir])
    empty_directory File.join(location, "public", options[:js_dir])
    empty_directory File.join(location, "public", options[:images_dir])
  end  
end

Middleman::Templates.register(:xhtml, Middleman::Templates::Xhtml)