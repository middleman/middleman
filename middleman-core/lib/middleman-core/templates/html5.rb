# HTML5 Boilerplate template
class Middleman::Templates::Html5 < Middleman::Templates::Base
  class_option 'css_dir',
               default: 'css',
               desc: 'The path to the css files'
  class_option 'js_dir',
               default: 'js',
               desc: 'The path to the javascript files'
  class_option 'images_dir',
               default: 'img',
               desc: 'The path to the image files'

  # Templates are relative to this file
  # @return [String]
  def self.source_root
    File.dirname(__FILE__)
  end

  # Output the files
  # @return [void]
  def build_scaffold!
    template 'shared/config.tt', File.join(location, 'config.rb'), force: options[:force]
    directory 'html5/source', File.join(location, 'source'), force: options[:force]
    empty_directory File.join(location, 'source'), force: options[:force]
  end
end

# Register the template
Middleman::Templates.register(:html5, Middleman::Templates::Html5)
