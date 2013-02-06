require 'active_support/core_ext/object/to_query'

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
          path = path.sub(/#{File.extname(path)}$/, ".#{asset_ext}")

          yield path if sitemap.find_resource_by_path(path)
        end

        # Generate body css classes based on the current path
        #
        # @return [String]
        def page_classes
          path = current_path.dup
          path << index_file if path.end_with?('/')
          path = Util.strip_leading_slash(path)

          classes = []
          parts = path.split('.').first.split('/')
          parts.each_with_index { |path, i| classes << parts.first(i+1).join('_') }

          classes.join(' ')
        end

        # Get the path of a file of a given type
        #
        # @param [Symbol] kind The type of file
        # @param [String] source The path to the file
        # @return [String]
        def asset_path(kind, source)
          return source if source.to_s.include?('//')
          asset_folder  = case kind
            when :css    then css_dir
            when :js     then js_dir
            when :images then images_dir
            else kind.to_s
          end
          source = source.to_s.tr(' ', '')
          ignore_extension = (kind == :images) # don't append extension
          source << ".#{kind}" unless ignore_extension || source.end_with?(".#{kind}")
          asset_folder = "" if source.start_with?('/') # absolute path

          asset_url(source, asset_folder)
        end

        # Given a source path (referenced either absolutely or relatively)
        # or a Resource, this will produce the nice URL configured for that
        # path, respecting :relative_links, directory indexes, etc.
        def url_for(path_or_resource, options={})
          # Handle Resources and other things which define their own url method
          url = path_or_resource.respond_to?(:url) ? path_or_resource.url : path_or_resource

          begin
            uri = URI(url)
          rescue URI::InvalidURIError
            # Nothing we can do with it, it's not really a URI
            return url
          end

          relative = options.delete(:relative)
          raise "Can't use the relative option with an external URL" if relative && uri.host

          # Allow people to turn on relative paths for all links with 
          # set :relative_links, true
          # but still override on a case by case basis with the :relative parameter.
          effective_relative = relative || false
          effective_relative = true if relative.nil? && relative_links

          # Try to find a sitemap resource corresponding to the desired path
          this_resource = current_resource # store in a local var to save work
          if path_or_resource.is_a?(Sitemap::Resource)
            resource = path_or_resource 
            resource_url = url
          elsif this_resource && uri.path
            # Handle relative urls
            url_path = Pathname(uri.path)
            current_source_dir = Pathname('/' + this_resource.path).dirname
            url_path = current_source_dir.join(url_path) if url_path.relative?
            resource = sitemap.find_resource_by_path(url_path.to_s)
            resource_url = resource.url if resource
          end

          if resource
            # Switch to the relative path between this_resource and the given resource
            # if we've been asked to.
            if effective_relative
              # Output urls relative to the destination path, not the source path
              current_dir = Pathname('/' + this_resource.destination_path).dirname
              relative_path = Pathname(resource_url).relative_path_from(current_dir).to_s

              # Put back the trailing slash to avoid unnecessary Apache redirects
              if resource_url.end_with?('/') && !relative_path.end_with?('/')
                relative_path << '/'
              end

              uri.path = relative_path
            else
              uri.path = resource_url
            end
          else
            # If they explicitly asked for relative links but we can't find a resource...
            raise "No resource exists at #{url}" if relative
          end
            
          # Support a :query option that can be a string or hash
          if query = options.delete(:query)
            uri.query = query.respond_to?(:to_param) ? query.to_param : query.to_s
          end

          # Support a :fragment or :anchor option just like Padrino
          fragment = options.delete(:anchor) || options.delete(:fragment)
          uri.fragment = fragment.to_s if fragment
          
          # Finally make the URL back into a string
          uri.to_s
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
        # 
        # There is also a :query option that can be used to append a
        # query string, which can be expressed as either a String,
        # or a Hash which will be turned into URL parameters.
        def link_to(*args, &block)
          url_arg_index = block_given? ? 0 : 1
          options_index = block_given? ? 1 : 2

          if block_given? && args.size > 2
            raise ArgumentError.new("Too many arguments to link_to(url, options={}, &block)")
          end

          if url = args[url_arg_index]
            options = args[options_index] || {}
            raise ArgumentError.new("Options must be a hash") unless options.is_a?(Hash)
            
            # Transform the url through our magic url_for method
            args[url_arg_index] = url_for(url, options)
          end
            
          super(*args, &block)
        end

        # Modified Padrino form_for that uses Middleman's url_for
        # to transform the URL.
        def form_tag(url, options={}, &block)
          url = url_for(url, options)
          super
        end
      end
    end
  end
end
