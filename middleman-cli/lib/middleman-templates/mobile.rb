# Mobile HTML5 Boilerplate
class Middleman::Templates::Mobile < Middleman::Templates::Base
  # Slightly different paths
  class_option :css_dir, default: 'css', desc: 'The path to the css files'
  class_option :js_dir, default: 'js', desc: 'The path to the javascript files'
  class_option :images_dir, default: 'img', desc: 'The path to the image files'

  # Template files are relative to this file
  # @return [String]
  def self.source_root
    File.dirname(__FILE__)
  end

  # Output the files
  # @return [void]
  def build_scaffold!
    template 'shared/config.tt', File.join(location, 'config.rb')
    directory 'mobile/source', File.join(location, 'source')
  end
end

# Register this template
Middleman::Templates.register(:mobile, Middleman::Templates::Mobile)
