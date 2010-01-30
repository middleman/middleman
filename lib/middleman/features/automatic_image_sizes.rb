require "middleman/fastimage"

class Middleman::Base
  alias_method :pre_automatic_image_tag, :image_tag
  helpers do
    def image_tag(path, params={})
      if !self.enabled?(:automatic_image_sizes)
        return pre_automatic_image_tag(path, params)
      end

      if (!params[:width] || !params[:height]) && !path.include?("://")
        params[:alt] ||= ""
        http_prefix = settings.http_images_path rescue settings.images_dir

        begin
          real_path = File.join(settings.public, settings.images_dir, path)
          if File.exists? real_path
            dimensions = Middleman::FastImage.size(real_path, :raise_on_failure => true)
            params[:width]  ||= dimensions[0]
            params[:height] ||= dimensions[1]
          end
        rescue
        end

        capture_haml { haml_tag(:img, params.merge(:src => asset_url(path, http_prefix))) }
      else
        pre_automatic_image_tag(path, params)
      end
    end
  end
end