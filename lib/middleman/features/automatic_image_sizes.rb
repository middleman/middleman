module Middleman::Features::AutomaticImageSizes
  class << self
    def registered(app)
      require "middleman/features/automatic_image_sizes/fastimage"

      app.helpers Helpers
    end
    alias :included :registered
  end
  
  module Helpers
    def image_tag(path, params={})
      if (!params[:width] || !params[:height]) && !path.include?("://")
        params[:alt] ||= ""
        http_prefix = settings.http_images_path rescue settings.images_dir

        begin
          real_path = File.join(settings.views, settings.images_dir, path)
          if File.exists? real_path
            dimensions = ::FastImage.size(real_path, :raise_on_failure => true)
            params[:width]  ||= dimensions[0]
            params[:height] ||= dimensions[1]
          end
        rescue
        end
      end
      
      super(path, params)
    end
  end
end