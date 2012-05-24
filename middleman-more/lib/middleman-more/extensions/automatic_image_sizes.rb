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
          if !params.has_key?(:width) && !params.has_key?(:height) && !path.include?("://")
            params[:alt] ||= ""
            http_prefix = http_images_path rescue images_dir

            begin
              real_path = File.join(source, images_dir, path)
              full_path = File.expand_path(real_path, root)
              http_prefix = http_images_path rescue images_dir
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
  end
end