require 'compass'

class Middleman::Base
  configure do
    ::Compass.configuration do |config|
      config.project_path     = Dir.pwd
      config.sass_dir         = File.join(File.basename(self.views), self.css_dir)
      config.output_style     = minify_css ? :compressed : :nested
      config.css_dir          = File.join(File.basename(self.public), self.css_dir)
      config.images_dir       = File.join(File.basename(self.public), self.images_dir)
      # File.expand_path(self.images_dir, self.public)

      if !cache_buster?
        config.asset_cache_buster do
          false
        end
      end
    
      config.http_images_path = "/#{self.images_dir}"
      config.http_stylesheets_path = "/#{self.css_dir}"
      config.add_import_path(config.sass_dir)
    end
    
    ::Compass.configure_sass_plugin!
  end
end