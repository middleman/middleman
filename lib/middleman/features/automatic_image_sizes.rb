require "middleman/fastimage"

class Middleman::Base
  alias_method :pre_automatic_image_tag, :image_tag
  helpers do
    def image_tag(path, params={})
      params[:alt] ||= ""
      prefix = options.http_images_path rescue options.images_dir
      
      if (!params[:width] || !params[:height]) && !path.include?("://")
        begin
          real_path = File.join(options.public, asset_url(path, prefix))
          if File.exists? real_path
            dimensions = Middleman::FastImage.size(real_path, :raise_on_failure => true)
            params[:width]  ||= dimensions[0]
            params[:height] ||= dimensions[1]
          end
        rescue
        end
      end
      
      params = params.merge(:src => asset_url(path, prefix))
      params = params.map { |k,v| %Q{#{k}="#{v}"}}.join(' ')
      "<img #{params} />"
    end
  end
end