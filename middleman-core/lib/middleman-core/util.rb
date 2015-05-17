# For instrumenting
require 'active_support/notifications'

# Using Thor's indifferent hash access
require 'thor'

# Core Pathname library used for traversal
require 'pathname'

# Template and Mime detection
require 'tilt'
require 'rack/mime'

module Middleman
  module Util
    class << self
      # Whether the source file is binary.
      #
      # @param [String] filename The file to check.
      # @return [Boolean]
      def binary?(filename)
        ext = File.extname(filename)

        # We hardcode detecting of gzipped SVG files
        return true if ext == '.svgz'

        return false if Tilt.registered?(ext.sub('.', ''))

        dot_ext = (ext.to_s[0] == '.') ? ext.dup : ".#{ext}"

        if mime = ::Rack::Mime.mime_type(dot_ext, nil)
          !nonbinary_mime?(mime)
        else
          file_contents_include_binary_bytes?(filename)
        end
      end

      # Facade for ActiveSupport/Notification
      def instrument(name, payload={}, &block)
        suffixed_name = (name =~ /\.middleman$/) ? name.dup : "#{name}.middleman"
        ::ActiveSupport::Notifications.instrument(suffixed_name, payload, &block)
      end

      # Recursively convert a normal Hash into a HashWithIndifferentAccess
      #
      # @private
      # @param [Hash] data Normal hash
      # @return [Thor::CoreExt::HashWithIndifferentAccess]
      def recursively_enhance(data)
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
      def normalize_path(path)
        # The tr call works around a bug in Ruby's Unicode handling
        URI.decode(path).sub(%r{^/}, '').tr('', '')
      end

      # This is a separate method from normalize_path in case we
      # change how we normalize paths
      def strip_leading_slash(path)
        path.sub(%r{^/}, '')
      end

      # Extract the text of a Rack response as a string.
      # Useful for extensions implemented as Rack middleware.
      # @param response The response from #call
      # @return [String] The whole response as a string.
      def extract_response_text(response)
        # The rack spec states all response bodies must respond to each
        result = ''
        response.each do |part, _|
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
      def path_match(matcher, path)
        case
        when matcher.is_a?(String)
          path.match(matcher)
        when matcher.respond_to?(:match)
          matcher.match(path)
        when matcher.respond_to?(:call)
          matcher.call(path)
        else
          File.fnmatch(matcher.to_s, path)
        end
      end

      # Get a recusive list of files inside a path.
      # Works with symlinks.
      #
      # @param path Some path string or Pathname
      # @param ignore A proc/block that returns true if a given path should be ignored - if a path
      #               is ignored, nothing below it will be searched either.
      # @return [Array<Pathname>] An array of Pathnames for each file (no directories)
      def all_files_under(path, &ignore)
        path = Pathname(path)

        return [] if ignore && ignore.call(path)

        if path.directory?
          path.children.flat_map do |child|
            all_files_under(child, &ignore)
          end.compact
        elsif path.file?
          [path]
        else
          []
        end
      end

      # Given a source path (referenced either absolutely or relatively)
      # or a Resource, this will produce the nice URL configured for that
      # path, respecting :relative_links, directory indexes, etc.
      def url_for(app, path_or_resource, options={})
        # Handle Resources and other things which define their own url method
        url = if path_or_resource.respond_to?(:url)
          path_or_resource.url
        else
          path_or_resource.dup
        end

        # Try to parse URL
        begin
          uri = URI(url)
        rescue URI::InvalidURIError
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
          resource_url = resource.url if resource
        elsif options[:find_resource] && uri.path && !uri.host
          resource = app.sitemap.find_resource_by_path(uri.path)
          resource_url = resource.url if resource
        end

        if resource
          uri.path = URI.encode(relative_path_from_resource(this_resource, resource_url, effective_relative))
        else
          # If they explicitly asked for relative links but we can't find a resource...
          raise "No resource exists at #{url}" if relative
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
      def full_path(path, app)
        resource = app.sitemap.find_resource_by_destination_path(path)

        unless resource
          # Try it with /index.html at the end
          indexed_path = File.join(path.sub(%r{/$}, ''), app.config[:index_file])
          resource = app.sitemap.find_resource_by_destination_path(indexed_path)
        end

        if resource
          '/' + resource.destination_path
        else
          '/' + normalize_path(path)
        end
      end

      # Glob a directory and try to keep path encoding consistent.
      #
      # @param [String] path The glob path.
      # @return [Array<String>]
      def glob_directory(path)
        results = ::Dir[path]

        return results unless RUBY_PLATFORM =~ /darwin/

        results.map { |r| r.encode('UTF-8', 'UTF-8-MAC') }
      end

      # Get the PWD and try to keep path encoding consistent.
      #
      # @param [String] path The glob path.
      # @return [Array<String>]
      def current_directory
        result = ::Dir.pwd

        return result unless RUBY_PLATFORM =~ /darwin/

        result.encode('UTF-8', 'UTF-8-MAC')
      end

      private

      # Is mime type known to be non-binary?
      #
      # @param [String] mime The mimetype to check.
      # @return [Boolean]
      def nonbinary_mime?(mime)
        case
        when mime.start_with?('text/')
          true
        when mime.include?('xml')
          true
        when mime.include?('json')
          true
        when mime.include?('javascript')
          true
        else
          false
        end
      end

      # Read a few bytes from the file and see if they are binary.
      #
      # @param [String] filename The file to check.
      # @return [Boolean]
      def file_contents_include_binary_bytes?(filename)
        binary_bytes = [0, 1, 2, 3, 4, 5, 6, 11, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 28, 29, 30, 31]
        s = File.read(filename, 4096) || ''
        s.each_byte do |c|
          return true if binary_bytes.include?(c)
        end

        false
      end

      # Get a relative path to a resource.
      #
      # @param [Middleman::Sitemap::Resource] curr_resource The resource.
      # @param [String] resource_url The target url.
      # @param [Boolean] relative If the path should be relative.
      # @return [String]
      def relative_path_from_resource(curr_resource, resource_url, relative)
        # Switch to the relative path between resource and the given resource
        # if we've been asked to.
        if relative && curr_resource
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
    end
  end
end
