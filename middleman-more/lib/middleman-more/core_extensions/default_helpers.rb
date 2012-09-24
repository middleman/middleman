module Middleman
  module CoreExtensions
    # Built-in helpers
    module DefaultHelpers

      # Extension registered
      class << self
        # @private
        def registered(app)
          require 'padrino-helpers'

          app.helpers ::Padrino::Helpers::OutputHelpers
          app.helpers ::Padrino::Helpers::TagHelpers
          app.helpers ::Padrino::Helpers::AssetTagHelpers
          app.helpers ::Padrino::Helpers::FormHelpers
          app.helpers ::Padrino::Helpers::FormatHelpers
          app.helpers ::Padrino::Helpers::RenderHelpers
          app.helpers ::Padrino::Helpers::NumberHelpers
          # app.helpers ::Padrino::Helpers::TranslationHelpers

          app.helpers Helpers

          app.set :relative_links, false
        end
        alias :included :registered
      end

      # The helpers
      module Helpers
        # Output a stylesheet link tag based on the current path
        #
        # @return [String]
        def auto_stylesheet_link_tag
          auto_tag(:css) do |path|
            stylesheet_link_tag path
          end
        end

        # Output a javascript tag based on the current path
        #
        # @return [String]
        def auto_javascript_include_tag
          auto_tag(:js) do |path|
            javascript_include_tag path
          end
        end

        # Output a stylesheet link tag based on the current path
        #
        # @param [Symbol] asset_ext The type of asset
        # @param [String] separator How to break up path in parts
        # @param [String] asset_dir Where to look for assets
        # @return [void]
        def auto_tag(asset_ext, asset_dir=nil)
          if asset_dir.nil?
            asset_dir = case asset_ext
              when :js  then js_dir
              when :css then css_dir
            end
          end

          # If the basename of the request as no extension, assume we are serving a
          # directory and join index_file to the path.
          path = File.join(asset_dir, current_path)
          path = path.gsub(File.extname(path), ".#{asset_ext}")

          yield path if sitemap.find_resource_by_path(path)
        end

        # Generate body css classes based on the current path
        #
        # @return [String]
        def page_classes
          path = current_path.dup
          path << index_file if path.match(%r{/$})
          path = path.gsub(%r{^/}, '')

          classes = []
          parts = path.split('.')[0].split('/')
          parts.each_with_index { |path, i| classes << parts.first(i+1).join('_') }

          classes.join(' ')
        end

        # Get the path of a file of a given type
        #
        # @param [Symbol] kind The type of file
        # @param [String] source The path to the file
        # @return [String]
        def asset_path(kind, source)
          return source if source =~ /^http/
          asset_folder  = case kind
            when :css    then css_dir
            when :js     then js_dir
            when :images then images_dir
            else kind.to_s
          end
          source = source.to_s.gsub(/\s/, '')
          ignore_extension = (kind == :images) # don't append extension
          source << ".#{kind}" unless ignore_extension or source =~ /\.#{kind}/
          if source =~ %r{^/} # absolute path
            asset_folder = ""
          end
          asset_url(source, asset_folder)
        end

        # Overload the regular link_to to be sitemap-aware - if you
        # reference a source path, either absolutely or relatively,
        # you'll get that resource's nice URL. Also, there is a
        # :relative option which, if set to true, will produce
        # relative URLs instead of absolute URLs. You can also add
        #
        # set :relative_links, true
        #
        # to config.rb to have all links default to relative.
        def link_to(*args, &block)
          url_arg_index = block_given? ? 0 : 1
          options_index = block_given? ? 1 : 2

          if url = args[url_arg_index]
            options = args[options_index] || {}
            relative = options.delete(:relative)

            # Handle Resources, which define their own url method
            if url.respond_to? :url
              args[url_arg_index] = url.url
            elsif url.include? '://'
              raise "Can't use the relative option with an external URL" if relative
            elsif current_resource
              # Handle relative urls
              current_source_dir = Pathname('/' + current_resource.path).dirname

              path = Pathname(url)

              url = current_source_dir.join(path).to_s if path.relative?

              resource = sitemap.find_resource_by_path(url)

              # Allow people to turn on relative paths for all links with set :relative_links, true
              # but still override on a case by case basis with the :relative parameter.
              effective_relative = relative || false
              if relative.nil? && relative_links
                effective_relative = true
              end

              if resource
                if effective_relative
                  resource_url = resource.url

                  # Output urls relative to the destination path, not the source path
                  current_dir = Pathname('/' + current_resource.destination_path).dirname
                  new_url = Pathname(resource_url).relative_path_from(current_dir).to_s

                  # Put back the trailing slash to avoid unnecessary Apache redirects
                  if resource_url.end_with?('/') && !new_url.end_with?('/')
                    new_url << '/'
                  end
                else
                  new_url = resource.url
                end

                args[url_arg_index] = new_url
              else
                raise "No resource exists at #{url}" if relative
              end
            end
          end

          super(*args, &block)
        end
      end
    end
  end
end
