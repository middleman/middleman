# Routing extension
module Middleman
  module CoreExtensions
    module Routing
      # The page method allows the layout to be set on a specific path
      #
      #   page "/about.html", layout: false
      #   page "/", layout: :homepage_layout
      #
      # @param [String] url
      # @param [Hash] opts
      # @return [void]
      def page(url, opts={})
        options = opts.dup

        # Default layout
        # TODO: This seems wrong
        options[:layout] = @app.config[:layout] if options[:layout].nil?
        # TODO: You can set options and locals, but not data
        metadata = { options: options, locals: options.delete(:locals) || {} }

        # If the url is a regexp
        unless url.is_a?(Regexp) || url.include?('*')
          # Normalized path
          url = '/' + Middleman::Util.normalize_path(url)
          if url.end_with?('/') || File.directory?(File.join(@app.source_dir, url))
            url = File.join(url, @app.config[:index_file])
          end

          # Setup proxy
          if target = options.delete(:proxy)
            # TODO: deprecate proxy through page?
            @app.proxy(url, target, opts.dup)
            return
          elsif options.delete(:ignore)
            # TODO: deprecate ignore through page?
            @app.ignore(url)
          end
        end

        # Setup a metadata matcher for rendering those options
        # TODO: How to get rid of this? Perhaps a separate extension that manipulates
        # in this sort of data?
        # This is harder because sitemap isn't available.
        @app.sitemap.provides_metadata_for_path(url) { |_| metadata }
      end
    end
  end
end
