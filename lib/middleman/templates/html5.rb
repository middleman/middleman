class Middleman::Templates::Html5 < Middleman::Templates::Base
  def self.source_root
    File.join(File.dirname(__FILE__), 'html5')
  end
  
  def build_scaffold
    template "config.tt", File.join(location, "config.rb")
    directory "public", File.join(location, "public")
    empty_directory File.join(location, "views")
  end
end

Middleman::Templates.register(:html5, Middleman::Templates::Html5)