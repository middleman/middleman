module Sprockets
  module Sass
    module Functions
      
      # Using Middleman::Util#asset_path, return the full path
      # for the given +source+ as a Sass String. This supports keyword
      # arguments that mirror the +options+.
      #
      # === Examples
      #
      #   background: url(image-path("image.jpg"));                // background: url("/assets/image.jpg");
      #   background: url(image-path("image.jpg", $digest: true)); // background: url("/assets/image-27a8f1f96afd8d4c67a59eb9447f45bd.jpg");
      #
      def image_path(source, options = {})
        p = ::Middleman::Util.asset_path(middleman_context, :images, source.value, map_options(options))
        ::Sass::Script::String.new p.to_s, :string
      end

      # Using Middleman::Util#asset_path, return the url CSS
      # for the given +source+ as a Sass String. This supports keyword
      # arguments that mirror the +options+.
      #
      # === Examples
      #
      #   background: image-url("image.jpg");                // background: url("/assets/image.jpg");
      #   background: image-url("image.jpg", $digest: true); // background: url("/assets/image-27a8f1f96afd8d4c67a59eb9447f45bd.jpg");
      #
      def image_url(source, options = {}, cache_buster = nil)
        # Work with the Compass #image_url API
        if options.respond_to? :value
          case options.value
          when true
            return image_path source
          else
            options = {}
          end
        end
        ::Sass::Script::String.new "url(#{image_path(source, options)})"
      end

      # Using Middleman::Util#asset_path, return the full path
      # for the given +source+ as a Sass String. This supports keyword
      # arguments that mirror the +options+.
      #
      # === Examples
      #
      #   src: url(font-path("font.ttf"));                // src: url("/assets/font.ttf");
      #   src: url(font-path("font.ttf", $digest: true)); // src: url("/assets/font-27a8f1f96afd8d4c67a59eb9447f45bd.ttf");
      #
      def font_path(source, options = {})
        p = ::Middleman::Util.asset_path(middleman_context, :fonts, source.value, map_options(options))
        ::Sass::Script::String.new p.to_s, :string
      end

      # Using Middleman::Util#asset_path, return the url CSS
      # for the given +source+ as a Sass String. This supports keyword
      # arguments that mirror the +options+.
      #
      # === Examples
      #
      #   src: font-url("font.ttf");                  // src: url("/assets/font.ttf");
      #   src: font-url("image.jpg", $digest: true);  // src: url("/assets/font-27a8f1f96afd8d4c67a59eb9447f45bd.ttf");
      #
      def font_url(source, options = {})
        # Work with the Compass #font_url API
        if options.respond_to? :value
          case options.value
          when true
            return font_path source
          else
            options = {}
          end
        end
        ::Sass::Script::String.new "url(#{font_path(source, options)})"
      end

      protected

      # Returns a reference to Middleman's context through
      # the importer.
      def middleman_context # :nodoc:
        options[:custom][:middleman_context]
      end

      # Returns an options hash where the keys are symbolized
      # and the values are unwrapped Sass literals.
      def map_options(options = {}) # :nodoc:
        ::Sass::Util.map_hash(options) do |key, value|
          [key.to_sym, value.respond_to?(:value) ? value.value : value]
        end
      end
    end
  end
end

module Sass::Script::Functions
  include Sprockets::Sass::Functions

  # Hack to ensure previous API declarations (by Compass or whatever)
  # don't take precedence.
  [:asset_path, :asset_url, :image_path, :image_url, :font_path, :font_url, :asset_data_uri].each do |method|
    defined?(@signatures) && @signatures.delete(method)
  end

  declare :asset_path,     [:source], :var_kwargs => true
  declare :asset_path,     [:source, :kind]
  declare :asset_url,      [:source], :var_kwargs => true
  declare :asset_url,      [:source, :kind]
  declare :image_path,     [:source], :var_kwargs => true
  declare :image_url,      [:source], :var_kwargs => true
  declare :image_url,      [:source, :only_path]
  declare :image_url,      [:source, :only_path, :cache_buster]
  declare :font_path,      [:source], :var_kwargs => true
  declare :font_url,       [:source], :var_kwargs => true
  declare :font_url,       [:source, :only_path]
  declare :asset_data_uri, [:source]
end
