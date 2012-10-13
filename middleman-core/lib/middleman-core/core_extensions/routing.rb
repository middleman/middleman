# Routing extension
module Middleman
  module CoreExtensions
    module Routing

      # Setup extension
      class << self

        # Once registered
        def registered(app)
          # Include methods
          app.send :include, InstanceMethods
        end

        alias :included :registered
      end

      # Routing instance methods
      module InstanceMethods

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
          old_layout = layout

          set :layout, layout_name
          instance_exec(&block) if block_given?
        ensure
          set :layout, old_layout
        end

        # The page method allows the layout to be set on a specific path
        #
        #   page "/about.html", :layout => false
        #   page "/", :layout => :homepage_layout
        #
        # @param [String] url
        # @param [Hash] opts
        # @return [void]
        def page(url, opts={}, &block)
          blocks = Array(block)

          # Default layout
          opts[:layout] = layout if opts[:layout].nil?

          # If the url is a regexp
          if url.is_a?(Regexp) || url.include?("*")

            # Use the metadata loop for matching against paths at runtime
            sitemap.provides_metadata_for_path url do |url|
              { :options => opts, :blocks => blocks }
            end

            return
          end

          # Normalized path
          url = '/' + Middleman::Util.normalize_path(url)
          if url.end_with?('/') || File.directory?(File.join(source_dir, url))
            url = File.join(url, index_file)
          end

          # Setup proxy
          if target = opts.delete(:proxy)
            # TODO: deprecate proxy through page?
            proxy(url, target, opts, &block) and return
          elsif opts.delete(:ignore)
            # TODO: deprecate ignore through page?
            ignore(url)
          end

          # Setup a metadata matcher for rendering those options
          sitemap.provides_metadata_for_path url do |url|
            { :options => opts, :blocks => blocks }
          end
        end
      end
    end
  end
end
