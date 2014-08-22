# Automatic Image Sizes extension
class Middleman::Extensions::AutomaticImageSizes < ::Middleman::Extension
  def initialize(app, options_hash={}, &block)
    super

    # Include 3rd-party fastimage library
    require 'vendored-middleman-deps/fastimage'
  end

  helpers do
    # Override default image_tag helper to automatically calculate and include
    # image dimensions.
    #
    # @param [String] path
    # @param [Hash] params
    # @return [String]
    def image_tag(path, params={})
      if !params.key?(:width) && !params.key?(:height) && !path.include?('://')
        real_path = path
        real_path = File.join(images_dir, real_path) unless real_path.start_with?('/')
        full_path = File.join(source_dir, real_path)

        if File.exist?(full_path)
          begin
            width, height = ::FastImage.size(full_path, raise_on_failure: true)
            params[:width]  = width
            params[:height] = height
          rescue FastImage::UnknownImageType
            # No message, it's just not supported
          rescue
            warn "Couldn't determine dimensions for image #{path}: #{$ERROR_INFO.message}"
          end
        end
      end

      super(path, params)
    end
  end
end
