# SMACSS
class Middleman::Templates::Smacss < Middleman::Templates::Base

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

  # Output the files
  # @return [void]
  def build_scaffold!
    template "shared/config.tt", File.join(location, "config.rb")
    directory "smacss/source", File.join(location, "source")
    empty_directory File.join(location, "source")
  end
end

# Register the template
Middleman::Templates.register(:smacss, Middleman::Templates::Smacss)
