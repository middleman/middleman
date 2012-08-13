# Mobile HTML5 Boilerplate
class Middleman::Templates::Mobile < Middleman::Templates::Base

  # Slightly different paths
  class_option :css_dir, :default => "css"
  class_option :js_dir, :default => "js"
  class_option :images_dir, :default => "img"

  # Template files are relative to this file
  # @return [String]
  def self.source_root
    File.dirname(__FILE__)
  end

  # Output the files
  # @return [void]
  def build_scaffold!
    template "shared/config.tt", File.join(location, "config.rb")
    directory "mobile/source", File.join(location, "source")
    empty_directory File.join(location, "source")
  end
end

# Register the template
Middleman::Templates.register(:mobile, Middleman::Templates::Mobile)
