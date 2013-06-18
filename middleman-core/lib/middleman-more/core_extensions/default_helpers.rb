# Required to hack around Padrino blocks within different template types.
require 'rbconfig'
if RUBY_VERSION =~ /1.8/ && RbConfig::CONFIG['ruby_install_name'] == 'ruby'
  begin
    require 'ruby18_source_location'
  rescue LoadError
    $stderr.puts "Ruby 1.8 requires the 'ruby18_source_location' gem be added to your Gemfile"
    exit(1)
  end
end

if !defined?(::Padrino::Helpers)
  require 'vendored-middleman-deps/padrino-core-0.11.2/lib/padrino-core/support_lite'
  require 'vendored-middleman-deps/padrino-helpers-0.11.2/lib/padrino-helpers'
end
    
class Padrino::Helpers::OutputHelpers::ErbHandler
  # Force Erb capture not to use safebuffer
  def capture_from_template(*args, &block)
    self.output_buffer, _buf_was = "", self.output_buffer
    captured_block = block.call(*args)
    ret = eval("@_out_buf", block.binding)
    self.output_buffer = _buf_was
    [ ret, captured_block ]
  end
end

class Middleman::CoreExtensions::DefaultHelpers < ::Middleman::Extension

  def initialize(app, options_hash={}, &block)
    super

    require 'active_support/core_ext/object/to_query'

    app.helpers ::Padrino::Helpers::OutputHelpers
    app.helpers ::Padrino::Helpers::TagHelpers
    app.helpers ::Padrino::Helpers::AssetTagHelpers
    app.helpers ::Padrino::Helpers::FormHelpers
    app.helpers ::Padrino::Helpers::FormatHelpers
    app.helpers ::Padrino::Helpers::RenderHelpers
    app.helpers ::Padrino::Helpers::NumberHelpers
    # app.helpers ::Padrino::Helpers::TranslationHelpers
    app.helpers ::Padrino::Helpers::Breadcrumbs

    app.config.define_setting :relative_links, false, 'Whether to generate relative links instead of absolute ones'
  end

  # The helpers
  helpers do

    # Make all block content html_safe
    def content_tag(name, content = nil, options = nil, &block)
      content = mark_safe(content) unless content.is_a?(Hash)
      mark_safe(super(name, content, options, &block))
    end

    def capture_html(*args, &block)
      handler = auto_find_proper_handler(&block)
      captured_block, captured_html = nil, ""
      if handler && handler.is_type? && handler.block_is_type?(block)
        captured_html, captured_block = handler.capture_from_template(*args, &block)
      end
      # invoking the block directly if there was no template
      captured_html = block_given? && ( captured_block || block.call(*args) )  if captured_html.blank?
      captured_html
    end

    def auto_find_proper_handler(&block)
      engine = block_given? ? File.extname(block.source_location[0])[1..-1].to_sym : current_engine
      ::Padrino::Helpers::OutputHelpers.handlers.map { |h| h.new(self) }.find { |h| h.engines.include?(engine) && h.is_type? }
    end

    # Disable Padrino cache buster
    def asset_stamp
      false
    end

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
      path = ::Middleman::Util.strip_leading_slash(path)

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
      return source if source.to_s.include?('//') || source.to_s.start_with?('data:')
      asset_folder  = case kind
        when :css    then css_dir
        when :js     then js_dir
        when :images then images_dir
        when :fonts  then fonts_dir
        else kind.to_s
      end
      source = source.to_s.tr(' ', '')
      ignore_extension = (kind == :images || kind == :fonts) # don't append extension
      source << ".#{kind}" unless ignore_extension || source.end_with?(".#{kind}")
      asset_folder = "" if source.start_with?('/') # absolute path

      asset_url(source, asset_folder)
    end

    # Get the URL of an asset given a type/prefix
    #
    # @param [String] path The path (such as "photo.jpg")
    # @param [String] prefix The type prefix (such as "images")
    # @return [String] The fully qualified asset url
    def asset_url(path, prefix="")
      # Don't touch assets which already have a full path
      if path.include?('//') or path.start_with?('data:')
        path
      else # rewrite paths to use their destination path
        path = File.join(prefix, path)
        if resource = sitemap.find_resource_by_path(path)
          resource.url
        else
          File.join(config[:http_prefix], path)
        end
      end
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
      effective_relative = true if relative.nil? && config[:relative_links]

      # Try to find a sitemap resource corresponding to the desired path
      this_resource = current_resource # store in a local var to save work
      if path_or_resource.is_a?(::Middleman::Sitemap::Resource)
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
    # config[:relative_links] = true
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
