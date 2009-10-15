require 'compass'

class Middleman::Base
  configure do
    ::Compass.configuration do |config|
      images_location = (self.environment == "build") ? self.build_dir : self.public
      
      config.project_path     = Dir.pwd
      config.sass_dir         = File.join(File.basename(self.views), self.css_dir)
      config.output_style     = self.minify_css? ? :compressed : :nested
      config.css_dir          = File.join(File.basename(images_location), self.css_dir)
      config.images_dir       = File.join(File.basename(images_location), self.images_dir)
      # File.expand_path(self.images_dir, self.public)

      if !cache_buster?
        config.asset_cache_buster do
          false
        end
      end
        
      config.http_images_path = File.join(self.http_prefix, self.images_dir)
      config.http_stylesheets_path = File.join(self.http_prefix, self.css_dir)
      config.add_import_path(config.sass_dir)
    end
    
    ::Compass.configure_sass_plugin!
  end
end