class Middleman::Features::AutomaticImageSizes
  def initialize(app)
    require "middleman/features/automatic_image_sizes/fastimage"

    Middleman::Base.send :alias_method, :pre_automatic_image_tag, :image_tag
    Middleman::Base.helpers do
      def image_tag(path, params={})
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
end

Middleman::Features.register :automatic_image_sizes, Middleman::Features::AutomaticImageSizes