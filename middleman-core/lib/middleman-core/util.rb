# For instrumenting
require 'active_support/notifications'

# Core Pathname library used for traversal
require 'pathname'

# Template and Mime detection
require 'tilt'
require 'rack/mime'

# DbC
require 'middleman-core/contracts'

# Indifferent Access
require 'hashie'

# For URI templating
require 'addressable/uri'
require 'addressable/template'
require 'active_support/inflector'
require 'active_support/inflector/transliterate'

module Middleman
  module Util
    include Contracts

    module_function

    # Whether the source file is binary.
    #
    # @param [String] filename The file to check.
    # @return [Boolean]
    Contract Or[String, Pathname] => Bool
    def binary?(filename)
      path = Pathname(filename)
      ext = path.extname

      # We hardcode detecting of gzipped SVG files
      return true if ext == '.svgz'

      return false if Tilt.registered?(ext.sub('.', ''))

      dot_ext = (ext.to_s[0] == '.') ? ext.dup : ".#{ext}"

      if mime = ::Rack::Mime.mime_type(dot_ext, nil)
        !nonbinary_mime?(mime)
      else
        file_contents_include_binary_bytes?(path.to_s)
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
      case
      when matcher.is_a?(String)
        if matcher.include? '*'
          File.fnmatch(matcher, path)
        else
          path == matcher
        end
      when matcher.respond_to?(:match)
        !matcher.match(path).nil?
      when matcher.respond_to?(:call)
        matcher.call(path)
      else
        File.fnmatch(matcher.to_s, path)
      end
    end

    class EnhancedHash < ::Hashie::Mash
      # include ::Hashie::Extensions::MergeInitializer
      # include ::Hashie::Extensions::MethodReader
      # include ::Hashie::Extensions::IndifferentAccess
    end

    # Recursively convert a normal Hash into a EnhancedHash
    #
    # @private
    # @param [Hash] data Normal hash
    # @return [Hash]
    Contract Maybe[Hash] => Maybe[Or[Array, EnhancedHash]]
    def recursively_enhance(obj)
      if obj.is_a? ::Array
        obj.map { |e| recursively_enhance(e) }
      elsif obj.is_a? ::Hash
        ::Hashie::Mash.new(obj)
      else
        obj
      end
    end

    # Normalize a path to not include a leading slash
    # @param [String] path
    # @return [String]
    Contract String => String
    def normalize_path(path)
      # The tr call works around a bug in Ruby's Unicode handling
      URI.decode(path).sub(%r{^/}, '').tr('', '')
    end

    # This is a separate method from normalize_path in case we
    # change how we normalize paths
    Contract String => String
    def strip_leading_slash(path)
      path.sub(%r{^/}, '')
    end

    # Facade for ActiveSupport/Notification
    def instrument(name, payload={}, &block)
      suffixed_name = (name =~ /\.middleman$/) ? name.dup : "#{name}.middleman"
      ::ActiveSupport::Notifications.instrument(suffixed_name, payload, &block)
    end

    # Extract the text of a Rack response as a string.
    # Useful for extensions implemented as Rack middleware.
    # @param response The response from #call
    # @return [String] The whole response as a string.
    Contract RespondTo[:each] => String
    def extract_response_text(response)
      # The rack spec states all response bodies must respond to each
      result = ''
      response.each do |part, _|
        result << part
      end
      result
    end

    # Get a recusive list of files inside a path.
    # Works with symlinks.
    #
    # @param path Some path string or Pathname
    # @param ignore A proc/block that returns true if a given path should be ignored - if a path
    #               is ignored, nothing below it will be searched either.
    # @return [Array<Pathname>] An array of Pathnames for each file (no directories)
    Contract Or[String, Pathname], Proc => ArrayOf[Pathname]
    def all_files_under(path, &ignore)
      path = Pathname(path)

      if path.directory?
        path.children.flat_map do |child|
          all_files_under(child, &ignore)
        end.compact
      elsif path.file?
        if block_given? && ignore.call(path)
          []
        else
          [path]
        end
      else
        []
      end
    end

    # Get the path of a file of a given type
    #
    # @param [Middleman::Application] app The app.
    # @param [Symbol] kind The type of file
    # @param [String, Symbol] source The path to the file
    # @param [Hash] options Data to pass through.
    # @return [String]
    Contract IsA['Middleman::Application'], Symbol, Or[String, Symbol], Hash => String
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
    Contract IsA['Middleman::Application'], String, String, Hash => String
    def asset_url(app, path, prefix='', options={})
      # Don't touch assets which already have a full path
      if path.include?('//') || path.start_with?('data:')
        path
      else # rewrite paths to use their destination path
        result = if resource = app.sitemap.find_resource_by_destination_path(url_for(app, path))
          resource.url
        else
          path = File.join(prefix, path)
          if resource = app.sitemap.find_resource_by_path(path)
            resource.url
          else
            File.join(app.config[:http_prefix], path)
          end
        end

        if options[:relative] != true
          result
        else
          unless options[:current_resource]
            raise ArgumentError, '#asset_url must be run in a context with current_resource if relative: true'
          end

          current_dir = Pathname('/' + options[:current_resource].destination_path)
          Pathname(result).relative_path_from(current_dir.dirname).to_s
        end
      end
    end

    # Given a source path (referenced either absolutely or relatively)
    # or a Resource, this will produce the nice URL configured for that
    # path, respecting :relative_links, directory indexes, etc.
    Contract IsA['Middleman::Application'], Or[String, IsA['Middleman::Sitemap::Resource']], Hash => String
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
          URI.encode(relative_path_from_resource(this_resource, resource_url, effective_relative))
        else
          resource_url
        end
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
    Contract String, IsA['Middleman::Application'] => String
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

    Contract String, String, ArrayOf[String], Proc => String
    def rewrite_paths(body, _path, exts, &_block)
      matcher = /([=\'\"\(,]\s*)([^\s\'\"\)>]+(#{Regexp.union(exts)}))/

      url_fn_prefix = 'url('

      body.dup.gsub(matcher) do |match|
        opening_character = $1
        asset_path = $2

        if asset_path.start_with?(url_fn_prefix)
          opening_character << url_fn_prefix
          asset_path = asset_path[url_fn_prefix.length..-1]
        end

        begin
          uri = ::Addressable::URI.parse(asset_path)

          if uri.relative? && uri.host.nil? && (result = yield(asset_path))
            "#{opening_character}#{result}"
          else
            match
          end
        rescue ::Addressable::URI::InvalidURIError
          match
        end
      end
    end

    # Is mime type known to be non-binary?
    #
    # @param [String] mime The mimetype to check.
    # @return [Boolean]
    Contract String => Bool
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
    Contract String => Bool
    def file_contents_include_binary_bytes?(filename)
      binary_bytes = [0, 1, 2, 3, 4, 5, 6, 11, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 28, 29, 30, 31]
      s = File.read(filename, 4096) || ''
      s.each_byte do |c|
        return true if binary_bytes.include?(c)
      end

      false
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

    # Get a relative path to a resource.
    #
    # @param [Middleman::Sitemap::Resource] curr_resource The resource.
    # @param [String] resource_url The target url.
    # @param [Boolean] relative If the path should be relative.
    # @return [String]
    Contract IsA['Middleman::Sitemap::Resource'], String, Bool => String
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

    Contract String => String
    def step_through_extensions(path)
      while ::Tilt[path]
        yield File.extname(path) if block_given?

        # Strip templating extensions as long as Tilt knows them
        path = path.sub(/#{::Regexp.escape(File.extname(path))}$/, '')
      end

      yield File.extname(path) if block_given?

      path
    end

    # Removes the templating extensions, while keeping the others
    # @param [String] path
    # @return [String]
    Contract String => String
    def remove_templating_extensions(path)
      step_through_extensions(path)
    end

    # Removes the templating extensions, while keeping the others
    # @param [String] path
    # @return [String]
    Contract String => ArrayOf[String]
    def collect_extensions(path)
      result = []

      step_through_extensions(path) { |e| result << e }

      result
    end

    # Convert a path to a file resprentation.
    #
    # @param [Pathname] path The path.
    # @return [Middleman::SourceFile]
    Contract Pathname, Pathname, Symbol, Bool => IsA['Middleman::SourceFile']
    def path_to_source_file(path, directory, type, destination_dir)
      types = Set.new([type])

      relative_path = path.relative_path_from(directory)
      relative_path   = File.join(destination_dir, relative_path) if destination_dir

      ::Middleman::SourceFile.new(Pathname(relative_path), path, directory, types)
    end

    # Finds files which should also be considered to be dirty when
    # the given file(s) are touched.
    #
    # @param [Middleman::Application] app The app.
    # @param [Pathname] files The original touched file paths.
    # @return [Middleman::SourceFile] All related file paths, not including the source file paths.
    Contract IsA['Middleman::Application'], ArrayOf[Pathname] => ArrayOf[IsA['Middleman::SourceFile']]
    def find_related_files(app, files)
      all_extensions = files.flat_map { |f| collect_extensions(f.to_s) }

      sass_type_aliasing = ['.scss', '.sass']
      erb_type_aliasing = ['.erb', '.haml', '.slim']

      if (all_extensions & sass_type_aliasing).length > 0
        all_extensions |= sass_type_aliasing
      end

      if (all_extensions & erb_type_aliasing).length > 0
        all_extensions |= erb_type_aliasing
      end

      all_extensions.uniq!

      app.sitemap.resources.select(&:file_descriptor).select { |r|
        local_extensions = collect_extensions(r.file_descriptor[:full_path].to_s)

        if (local_extensions & sass_type_aliasing).length > 0
          local_extensions |= sass_type_aliasing
        end

        if (local_extensions & erb_type_aliasing).length > 0
          local_extensions |= erb_type_aliasing
        end

        local_extensions.uniq!

        ((all_extensions & local_extensions).length > 0) && files.none? { |f| f == r.file_descriptor[:full_path] }
      }.map(&:file_descriptor)
    end

    # Handy methods for dealing with URI templates. Mix into whatever class.
    module UriTemplates
      module_function

      # Given a URI template string, make an Addressable::Template
      # This supports the legacy middleman-blog/Sinatra style :colon
      # URI templates as well as RFC6570 templates.
      #
      # @param [String] tmpl_src URI template source
      # @return [Addressable::Template] a URI template
      def uri_template(tmpl_src)
        # Support the RFC6470 templates directly if people use them
        if tmpl_src.include?(':')
          tmpl_src = tmpl_src.gsub(/:([A-Za-z0-9]+)/, '{\1}')
        end

        Addressable::Template.new ::Middleman::Util.normalize_path(tmpl_src)
      end

      # Apply a URI template with the given data, producing a normalized
      # Middleman path.
      #
      # @param [Addressable::Template] template
      # @param [Hash] data
      # @return [String] normalized path
      def apply_uri_template(template, data)
        ::Middleman::Util.normalize_path Addressable::URI.unencode(template.expand(data)).to_s
      end

      # Use a template to extract parameters from a path, and validate some special (date)
      # keys. Returns nil if the special keys don't match.
      #
      # @param [Addressable::Template] template
      # @param [String] path
      def extract_params(template, path)
        template.extract(path, BlogTemplateProcessor)
      end

      # Parameterize a string preserving any multibyte characters
      def safe_parameterize(str)
        sep = '-'

        # Reimplementation of http://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-parameterize that preserves un-transliterate-able multibyte chars.
        parameterized_string = ActiveSupport::Inflector.transliterate(str.to_s).downcase
        parameterized_string.gsub!(/[^a-z0-9\-_\?]+/, sep)

        parameterized_string.chars.to_a.each_with_index do |char, i|
          next unless char == '?' && str[i].bytes.count != 1
          parameterized_string[i] = str[i]
        end

        re_sep = Regexp.escape(sep)
        # No more than one of the separator in a row.
        parameterized_string.gsub!(/#{re_sep}{2,}/, sep)
        # Remove leading/trailing separator.
        parameterized_string.gsub!(/^#{re_sep}|#{re_sep}$/, '')

        parameterized_string
      end

      # Convert a date into a hash of components to strings
      # suitable for using in a URL template.
      # @param [DateTime] date
      # @return [Hash] parameters
      def date_to_params(date)
        {
          year: date.year.to_s,
          month: date.month.to_s.rjust(2, '0'),
          day: date.day.to_s.rjust(2, '0')
        }
      end
    end

    # A special template processor that validates date fields
    # and has an extra-permissive default regex.
    #
    # See https://github.com/sporkmonger/addressable/blob/master/lib/addressable/template.rb#L279
    class BlogTemplateProcessor
      def self.match(name)
        case name
        when 'year' then '\d{4}'
        when 'month' then '\d{2}'
        when 'day' then '\d{2}'
        else '.*?'
        end
      end
    end
  end
end
