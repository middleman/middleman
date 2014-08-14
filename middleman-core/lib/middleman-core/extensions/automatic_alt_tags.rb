# Automatic Image alt tags from image names extension
class Middleman::Extensions::AutomaticAltTags < ::Middleman::Extension
  helpers do
    # Override default image_tag helper to automatically insert alt tag
    # containing image name.

    def image_tag(path, params={})
      unless path.include?('://')
        params[:alt] ||= ''

        real_path = path.dup
        real_path = File.join(config[:images_dir], real_path) unless real_path.start_with?('/')

        file = app.files.find(:source, real_path)

        if file && file[:full_path].exist?
          begin
            alt_text = File.basename(file[:full_path].to_s, '.*')
            alt_text.capitalize!
            params[:alt] = alt_text
          end
        end
      end

      super(path, params)
    end
  end
end
