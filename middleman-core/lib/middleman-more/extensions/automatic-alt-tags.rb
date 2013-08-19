# Automatic Image alt tags from image names extension
class Middleman::Extensions::AutomaticAltTags < ::Middleman::Extension

  def initialize(app, options_hash={}, &block)
    super
  end

  helpers do
    # Override default image_tag helper to automatically insert alt tag
    # containing image name.
    
    def image_tag(path)
      if !path.include?("://")
        params[:alt] ||= ""

        real_path = path
        real_path = File.join(images_dir, real_path) unless real_path.start_with?('/')
        full_path = File.join(source_dir, real_path)

        if File.exists?(full_path)
          begin
            alt_text = File.basename(full_path, ".*")
            alt_text.capitalize!
            params[:alt] = alt_text
          end
        end
      end

      super(path)
    end
  end
end
