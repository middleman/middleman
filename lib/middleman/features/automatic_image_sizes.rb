module Middleman::Features::AutomaticImageSizes
  class << self
    def registered(app)
      require "middleman/features/automatic_image_sizes/fastimage"

      app.send :include, InstanceMethods
    end
    alias :included :registered
  end
  
  module InstanceMethods
    def image_tag(path, params={})
      if !params.has_key?(:width) && !params.has_key?(:height) && !path.include?("://")
        params[:alt] ||= ""
        http_prefix = self.http_images_path rescue self.images_dir

        begin
          real_path = File.join(self.views, self.images_dir, path)
          full_path = File.expand_path(real_path, self.root)
          http_prefix = self.http_images_path rescue self.images_dir
          if File.exists? full_path
            dimensions = ::FastImage.size(full_path, :raise_on_failure => true)
            params[:width]  = dimensions[0]
            params[:height] = dimensions[1]
          end
        rescue
          # $stderr.puts params.inspect
        end
      end
      
      super(path, params)
    end
  end
end