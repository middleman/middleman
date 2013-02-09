# Extensions namespace
module Middleman
  module Extensions

    # Automatic Image Sizes extension
    module AutomaticImageSizes

      # Setup extension
      class << self

        # Once registered
        def registered(app)
          # Include 3rd-party fastimage library
          require "middleman-more/extensions/automatic_image_sizes/fastimage"

          # Include methods
          app.send :include, InstanceMethods
        end

        alias :included :registered
      end

      # Automatic Image Sizes Instance Methods
      module InstanceMethods

        # Override default image_tag helper to automatically calculate and include
        # image dimensions.
        #
        # @param [String] path
        # @param [Hash] params
        # @return [String]
        def image_tag(path, params={})
          params[:supported_extensions] ||= %w(.png .jpg .jpeg .bmp .gif)
          
          if !params.has_key?(:width) && !params.has_key?(:height) && !path.include?("://") &&
            params[:supported_extensions].include?(File.extname(path).downcase)
            
            params[:alt] ||= ""

            real_path = path
            real_path = File.join(images_dir, real_path) unless real_path.start_with?('/')
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
          end
          
          params = params.delete_if {|key| key == :supported_extensions }

          super(path, params)
        end
      end
    end
  end
end
