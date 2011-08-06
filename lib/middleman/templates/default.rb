class Middleman::Templates::Default < Middleman::Templates::Base
  def self.source_root
    File.dirname(__FILE__)
  end
  
  def build_scaffold
    template "shared/config.tt", File.join(location, "config.rb")
    copy_file "default/source/index.html.erb", File.join(location, "source/index.html.erb")
    copy_file "default/source/layout.erb", File.join(location, "source/layout.erb")
    empty_directory File.join(location, "source", options[:css_dir])
    copy_file "default/source/stylesheets/site.css.scss", File.join(location, "source", options[:css_dir], "site.css.scss")
    empty_directory File.join(location, "source", options[:js_dir])
    empty_directory File.join(location, "source", options[:images_dir])
  end  
end

Middleman::Templates.register(:default, Middleman::Templates::Default)