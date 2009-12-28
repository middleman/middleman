require "middleman/fastimage"

class Middleman::Base
  alias_method :pre_automatic_image_tag, :image_tag
  helpers do
    def image_tag(path, params={})
      if !options.respond_to?(:automatic_image_sizes?) || !options.automatic_image_sizes?
        return pre_automatic_image_tag(path, params)
      end

      if (!params[:width] || !params[:height]) && !path.include?("://")
        params[:alt] ||= ""
        http_prefix = options.http_images_path rescue options.images_dir

        begin
          real_path = File.join(options.public, options.images_dir, path)
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