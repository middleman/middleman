# Our custom logger
require "middleman-core/logger"

# For instrumenting
require "active_support/notifications"

# Using Thor's indifferent hash access
require "thor"

# Core Pathname library used for traversal
require "pathname"

require "tilt"
require "rack/mime"

module Middleman

  module Util

    # Whether the source file is binary.
    #
    # @param [String] filename The file to check.
    # @return [Boolean]
    def self.binary?(filename)
      ext = File.extname(filename)
      return true if ext == '.svgz'
      return false if Tilt.registered?(ext.sub('.',''))

      ext = ".#{ext}" unless ext.to_s[0] == ?.
      mime = ::Rack::Mime.mime_type(ext, nil)
      unless mime
        binary_bytes = [0, 1, 2, 3, 4, 5, 6, 11, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 28, 29, 30, 31]
        s = File.read(filename, 4096) || ''
        s.each_byte do |c|
          return true if binary_bytes.include?(c)
        end
        return false
      end
      return false if mime.start_with?('text/')
      return false if mime.include?('xml')
      return false if mime.include?('json')
      return false if mime.include?('javascript')
      true
    end

    # The logger
    #
    # @return [Middleman::Logger] The logger
    def self.logger(*args)
      if !@_logger || args.length > 0
        if args.length == 1 && (args.first.is_a?(::String) || args.first.respond_to?(:write))
          args = [0, false, args.first]
        end
        @_logger = ::Middleman::Logger.new(*args)
      end

      @_logger
    end

    # Facade for ActiveSupport/Notification
    def self.instrument(name, payload={}, &block)
      name << ".middleman" unless name =~ /\.middleman$/
      ::ActiveSupport::Notifications.instrument(name, payload, &block)
    end

    # Recursively convert a normal Hash into a HashWithIndifferentAccess
    #
    # @private
    # @param [Hash] data Normal hash
    # @return [Thor::CoreExt::HashWithIndifferentAccess]
    def self.recursively_enhance(data)
      if data.is_a? Hash
        data = ::Thor::CoreExt::HashWithIndifferentAccess.new(data)
        data.each do |key, val|
          data[key] = recursively_enhance(val)
        end
        data
      elsif data.is_a? Array
        data.each_with_index do |val, i|
          data[i] = recursively_enhance(val)
        end
        data
      else
        data
      end
    end

    # Normalize a path to not include a leading slash
    # @param [String] path
    # @return [String]
    def self.normalize_path(path)
      # The tr call works around a bug in Ruby's Unicode handling
      path.sub(%r{^/}, "").tr('','')
    end

    # This is a separate method from normalize_path in case we
    # change how we normalize paths
    def self.strip_leading_slash(path)
      path.sub(%r{^/}, "")
    end

    # Extract the text of a Rack response as a string.
    # Useful for extensions implemented as Rack middleware.
    # @param response The response from #call
    # @return [String] The whole response as a string.
    def self.extract_response_text(response)
      # The rack spec states all response bodies must respond to each
      result = ''
      response.each do |part, s|
        result << part
      end
      result
    end

    # Takes a matcher, which can be a literal string
    # or a string containing glob expressions, or a
    # regexp, or a proc, or anything else that responds
    # to #match or #call, and returns whether or not the
    # given path matches that matcher.
    #
    # @param matcher A matcher string/regexp/proc/etc
    # @param path A path as a string
    # @return [Boolean] Whether the path matches the matcher
    def self.path_match(matcher, path)
      if matcher.is_a? String
        path.match matcher
      elsif matcher.respond_to? :match
        matcher.match path
      elsif matcher.respond_to? :call
        matcher.call path
      else
        File.fnmatch(matcher.to_s, path)
      end
    end

    # Get a recusive list of files inside a set of paths.
    # Works with symlinks.
    #
    # @param paths Some paths string or Pathname
    # @return [Array] An array of filenames
    def self.all_files_under(*paths)
      # when we drop 1.8, replace this with flat_map
      paths.map do |p|
        path = Pathname(p)
        if path.directory?
          all_files_under(*path.children)
        elsif path.file?
          path
        end
      end.flatten.compact
    end

    # Given a source path (referenced either absolutely or relatively)
    # or a Resource, this will produce the nice URL configured for that
    # path, respecting :relative_links, directory indexes, etc.
    def self.url_for(app, path_or_resource, options={})
      # Handle Resources and other things which define their own url method
      url = path_or_resource.respond_to?(:url) ? path_or_resource.url : path_or_resource
      url = url.gsub(' ', '%20')

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
      effective_relative = true if relative.nil? && app.config[:relative_links]

      # Try to find a sitemap resource corresponding to the desired path
      this_resource = app.current_resource # store in a local var to save work

      if path_or_resource.is_a?(::Middleman::Sitemap::Resource)
        resource = path_or_resource
        resource_url = url
      elsif this_resource && uri.path
        # Handle relative urls
        url_path = Pathname(uri.path)
        current_source_dir = Pathname('/' + this_resource.path).dirname
        url_path = current_source_dir.join(url_path) if url_path.relative?
        resource = app.sitemap.find_resource_by_path(url_path.to_s)
        resource_url = resource.url if resource
      elsif options[:find_resource] && uri.path
        resource = app.sitemap.find_resource_by_path(uri.path)
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
  end
end
