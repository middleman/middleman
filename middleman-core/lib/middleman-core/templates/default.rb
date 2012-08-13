# Default Middleman template
class Middleman::Templates::Default < Middleman::Templates::Base

  class_option "css_dir",
    :default => "stylesheets",
    :desc    => 'The path to the css files'
  class_option "js_dir",
    :default => "javascripts",
    :desc    => 'The path to the javascript files'
  class_option "images_dir",
    :default => "images",
    :desc    => 'The path to the image files'

  # Template files are relative to this file
  # @return [String]
  def self.source_root
    File.dirname(__FILE__)
  end

  # Actually output the files
  # @return [void]
  def build_scaffold!
    template "shared/config.tt", File.join(location, "config.rb")
    copy_file "default/source/index.html.erb", File.join(location, "source/index.html.erb")
    copy_file "default/source/layouts/layout.erb", File.join(location, "source/layouts/layout.erb")
    empty_directory File.join(location, "source", options[:css_dir])
    copy_file "default/source/stylesheets/all.css", File.join(location, "source", options[:css_dir], "all.css")
    copy_file "default/source/stylesheets/normalize.css", File.join(location, "source", options[:css_dir], "normalize.css")
    empty_directory File.join(location, "source", options[:js_dir])
    copy_file "default/source/javascripts/all.js", File.join(location, "source", options[:js_dir], "all.js")
    empty_directory File.join(location, "source", options[:images_dir])
    copy_file "default/source/images/background.png", File.join(location, "source", options[:images_dir], "background.png")
    copy_file "default/source/images/middleman.png", File.join(location, "source", options[:images_dir], "middleman.png")
  end
end

# Register this template
Middleman::Templates.register(:default, Middleman::Templates::Default)
