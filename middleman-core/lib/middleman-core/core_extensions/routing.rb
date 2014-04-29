# Routing extension
module Middleman
  module CoreExtensions
    module Routing
      # Sandboxed layout to implement temporary overriding of layout.
      class LayoutBlock
        attr_reader :scope

        def initialize(scope, layout_name)
          @scope = scope
          @layout_name = layout_name
        end

        def page(url, opts={})
          opts[:layout] ||= @layout_name
          @scope.page(url, opts)
        end

        delegate :proxy, to: :scope
      end

      # Takes a block which allows many pages to have the same layout
      #
      #   with_layout :admin do
      #     page "/admin/"
      #     page "/admin/login.html"
      #   end
      #
      # @param [String, Symbol] layout_name
      # @return [void]
      def with_layout(layout_name, &block)
        LayoutBlock.new(self, layout_name).instance_eval(&block)
      end

      # The page method allows the layout to be set on a specific path
      #
      #   page "/about.html", :layout => false
      #   page "/", :layout => :homepage_layout
      #
      # @param [String] url
      # @param [Hash] opts
      # @return [void]
      def page(url, opts={})
        options = opts.dup

        # Default layout
        options[:layout] = @app.config[:layout] if options[:layout].nil?
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
        @app.sitemap.provides_metadata_for_path(url) { |_| metadata }
      end
    end
  end
end
