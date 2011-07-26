class Middleman::Templates::Html5 < Middleman::Templates::Base
  class_option :css_dir, :default => "css"
  class_option :js_dir, :default => "js"

  def self.source_root
    File.dirname(__FILE__)
  end
  
  def build_scaffold
    template "shared/config.tt", File.join(location, "config.rb")
    directory "html5/source", File.join(location, "source")
    empty_directory File.join(location, "source")
  end
end

Middleman::Templates.register(:html5, Middleman::Templates::Html5)