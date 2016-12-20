# Core Pathname library used for traversal
require 'pathname'
require 'uri'
require 'addressable/uri'
require 'memoist'
require 'tilt'

require 'middleman-core/contracts'

# rubocop:disable ModuleLength
module Middleman
  module Util
    extend Memoist
    include Contracts

    module_function

    Contract String => ::Addressable::URI
    def parse_uri(uri)
      ::Addressable::URI.parse(uri)
    end
    memoize :parse_uri

    Contract String => Any
    def tilt_class(path)
      ::Tilt[path]
    end
    memoize :tilt_class

    # Normalize a path to not include a leading slash
    # @param [String] path
    # @return [String]
    Contract String => String
    def normalize_path(path)
      # The tr call works around a bug in Ruby's Unicode handling
      ::URI.decode(path).sub(%r{^/}, '').tr('', '')
    end
    memoize :normalize_path

    # This is a separate method from normalize_path in case we
    # change how we normalize paths
    Contract String => String
    def strip_leading_slash(path)
      path.sub(%r{^/}, '')
    end
    memoize :strip_leading_slash

    IGNORE_DESCRIPTOR = Or[Regexp, RespondTo[:call], String]
    Contract IGNORE_DESCRIPTOR, String => Bool
    def should_ignore?(validator, value)
      if validator.is_a? Regexp
        # Treat as Regexp
        !!(value =~ validator)
      elsif validator.respond_to? :call
        # Treat as proc
        validator.call(value)
      elsif validator.is_a? String
        # Treat as glob
        File.fnmatch(value, validator)
      else
        # If some unknown thing, don't ignore
        false
      end
    end
    memoize :should_ignore?

    # Get the path of a file of a given type
    #
    # @param [Middleman::Application] app The app.
    # @param [Symbol] kind The type of file
    # @param [String, Symbol] source The path to the file
    # @param [Hash] options Data to pass through.
    # @return [String]
    Contract ::Middleman::Application, Symbol, Or[String, Symbol], Hash => String
    def asset_path(app, kind, source, options={})
      return source if source.to_s.include?('//') || source.to_s.start_with?('data:')

      asset_folder = case kind
      when :css
        app.config[:css_dir]
      when :js
        app.config[:js_dir]
      when :images
        app.config[:images_dir]
      when :fonts
        app.config[:fonts_dir]
      else
        kind.to_s
      end

      source = source.to_s.tr(' ', '')
      ignore_extension = (kind == :images || kind == :fonts) # don't append extension
      source << ".#{kind}" unless ignore_extension || source.end_with?(".#{kind}")
      asset_folder = '' if source.start_with?('/') # absolute path

      asset_url(app, source, asset_folder, options)
    end

    # Get the URL of an asset given a type/prefix
    #
    # @param [String] path The path (such as "photo.jpg")
    # @param [String] prefix The type prefix (such as "images")
    # @param [Hash] options Data to pass through.
    # @return [String] The fully qualified asset url
    Contract ::Middleman::Application, String, String, Hash => String
    def asset_url(app, path, prefix='', options={})
      # Don't touch assets which already have a full path
      return path if path.include?('//') || path.start_with?('data:')

      if options[:relative] && !options[:current_resource]
        raise ArgumentError, '#asset_url must be run in a context with current_resource if relative: true'
      end

      uri = ::Middleman::Util.parse_uri(path)
      path = uri.path

      # Ensure the url we pass into find_resource_by_destination_path is not a
      # relative path, since it only takes absolute url paths.
      dest_path = url_for(app, path, options.merge(relative: false))

      result = if resource = app.sitemap.find_resource_by_path(dest_path)
        resource.url
      elsif resource = app.sitemap.find_resource_by_destination_path(dest_path)
        resource.url
      else
        path = ::File.join(prefix, path)
        if resource = app.sitemap.find_resource_by_path(path)
          resource.url
        else
          ::File.join(app.config[:http_prefix], path)
        end
      end

      final_result = ::Addressable::URI.encode(
        relative_path_from_resource(
          options[:current_resource],
          result,
          options[:relative]
        )
      )

      result_uri = ::Middleman::Util.parse_uri(final_result)
      result_uri.query = uri.query
      result_uri.fragment = uri.fragment
      result_uri.to_s
    end

    # Given a source path (referenced either absolutely or relatively)
    # or a Resource, this will produce the nice URL configured for that
    # path, respecting :relative_links, directory indexes, etc.
    Contract ::Middleman::Application, Or[String, Symbol, ::Middleman::Sitemap::Resource], Hash => String
    def url_for(app, path_or_resource, options={})
      if path_or_resource.is_a?(String) || path_or_resource.is_a?(Symbol)
        r = app.sitemap.find_resource_by_page_id(path_or_resource)

        path_or_resource = r ? r : path_or_resource.to_s
      end

      # Handle Resources and other things which define their own url method
      url = if path_or_resource.respond_to?(:url)
        path_or_resource.url
      else
        path_or_resource.dup
      end

      # Try to parse URL
      begin
        uri = ::Middleman::Util.parse_uri(url)
      rescue ::Addressable::URI::InvalidURIError
        # Nothing we can do with it, it's not really a URI
        return url
      end

      relative = options[:relative]
      raise "Can't use the relative option with an external URL" if relative && uri.host

      # Allow people to turn on relative paths for all links with
      # set :relative_links, true
      # but still override on a case by case basis with the :relative parameter.
      effective_relative = relative || false
      effective_relative = true if relative.nil? && app.config[:relative_links]

      # Try to find a sitemap resource corresponding to the desired path
      this_resource = options[:current_resource]

      if path_or_resource.is_a?(::Middleman::Sitemap::Resource)
        resource = path_or_resource
        resource_url = url
      elsif this_resource && uri.path && !uri.host
        # Handle relative urls
        url_path = Pathname(uri.path)
        current_source_dir = Pathname('/' + this_resource.path).dirname
        url_path = current_source_dir.join(url_path) if url_path.relative?
        resource = app.sitemap.find_resource_by_path(url_path.to_s)
        if resource
          resource_url = resource.url
        else
          # Try to find a resource relative to destination paths
          url_path = Pathname(uri.path)
          current_source_dir = Pathname('/' + this_resource.destination_path).dirname
          url_path = current_source_dir.join(url_path) if url_path.relative?
          resource = app.sitemap.find_resource_by_destination_path(url_path.to_s)
          resource_url = resource.url if resource
        end
      elsif options[:find_resource] && uri.path && !uri.host
        resource = app.sitemap.find_resource_by_path(uri.path)
        resource_url = resource.url if resource
      end

      if resource
        uri.path = if this_resource
          ::Addressable::URI.encode(
            relative_path_from_resource(
              this_resource,
              resource_url,
              effective_relative
            )
          )
        else
          resource_url
        end
      end

      # Support a :query option that can be a string or hash
      if query = options[:query]
        uri.query = query.respond_to?(:to_param) ? query.to_param : query.to_s
      end

      # Support a :fragment or :anchor option just like Padrino
      fragment = options[:anchor] || options[:fragment]
      uri.fragment = fragment.to_s if fragment

      # Finally make the URL back into a string
      uri.to_s
    end

    # Expand a path to include the index file if it's a directory
    #
    # @param [String] path Request path/
    # @param [Middleman::Application] app The requesting app.
    # @return [String] Path with index file if necessary.
    Contract String, ::Middleman::Application => String
    def full_path(path, app)
      resource = app.sitemap.find_resource_by_destination_path(path)

      unless resource
        # Try it with /index.html at the end
        indexed_path = ::File.join(path.sub(%r{/$}, ''), app.config[:index_file])
        resource = app.sitemap.find_resource_by_destination_path(indexed_path)
      end

      if resource
        '/' + resource.destination_path
      else
        '/' + normalize_path(path)
      end
    end

    # Get a relative path to a resource.
    #
    # @param [Middleman::Sitemap::Resource] curr_resource The resource.
    # @param [String] resource_url The target url.
    # @param [Boolean] relative If the path should be relative.
    # @return [String]
    Contract ::Middleman::Sitemap::Resource, String, Bool => String
    def relative_path_from_resource(curr_resource, resource_url, relative)
      # Switch to the relative path between resource and the given resource
      # if we've been asked to.
      if relative
        # Output urls relative to the destination path, not the source path
        current_dir = Pathname('/' + curr_resource.destination_path).dirname
        relative_path = Pathname(resource_url).relative_path_from(current_dir).to_s

        # Put back the trailing slash to avoid unnecessary Apache redirects
        if resource_url.end_with?('/') && !relative_path.end_with?('/')
          relative_path << '/'
        end

        relative_path
      else
        resource_url
      end
    end

    # Takes a matcher, which can be a literal string
    # or a string containing glob expressions, or a
    # regexp, or a proc, or anything else that responds
    # to #match or #call, and returns whether or not the
    # given path matches that matcher.
    #
    # @param [String, #match, #call] matcher A matcher String, RegExp, Proc, etc.
    # @param [String] path A path as a string
    # @return [Boolean] Whether the path matches the matcher
    Contract PATH_MATCHER, String => Bool
    def path_match(matcher, path)
      if matcher.is_a?(String)
        if matcher.include? '*'
          ::File.fnmatch(matcher, path)
        else
          path == matcher
        end
      elsif matcher.respond_to?(:match)
        !!(path =~ matcher)
      elsif matcher.respond_to?(:call)
        matcher.call(path)
      else
        ::File.fnmatch(matcher.to_s, path)
      end
    end
    memoize :path_match
  end
end
