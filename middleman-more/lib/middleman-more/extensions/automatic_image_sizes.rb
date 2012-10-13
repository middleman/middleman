# Extensions namespace
module Middleman
  module Extensions

    # Automatic Image Sizes extension
    class AutomaticImageSizes < ::Middleman::Extension
    
      def initialize(*args)
        # Include 3rd-party fastimage library
        require "middleman-more/extensions/automatic_image_sizes/fastimage"
      
        super
      end
      
      # Automatic Image Sizes Instance Methods
      helpers do
        # Override default image_tag helper to automatically calculate and include
        # image dimensions.
        #
        # @param [String] path
        # @param [Hash] params
        # @return [String]
        def image_tag(path, params={})
          if params.has_key?(:width) || params.has_key?(:height) || path.include?("://")
            return super
          end
          
          params[:alt] ||= ""

          real_path = path.dup
          real_path = File.join(images_dir, real_path) unless real_path =~ %r{^/}
          full_path = File.join(source_dir, real_path)

          if File.exists? full_path
            begin
              width, height = ::FastImage.size(full_path, :raise_on_failure => true)
              params[:width]  = width
              params[:height] = height
            rescue
              warn "Couldn't determine dimensions for image #{path}: #{$!.message}"
            end
          end

          super(path, params)
        end
      end
    end
  end
end
