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
      if block_given?
        options = content if content.is_a?(Hash)
        content = capture_html(&block)
      end

      options    = parse_data_options(name, options)
      attributes = tag_attributes(options)
      output = ActiveSupport::SafeBuffer.new
      output.safe_concat "<#{name}#{attributes}>"
      if content.respond_to?(:each) && !content.is_a?(String)
        content.each { |c| output.safe_concat c; output.safe_concat NEWLINE }
      else
        output.safe_concat "#{content}"
      end
      output.safe_concat "</#{name}>"

      block_is_template?(block) ? concat_content(output) : output
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
      path = path.sub(/#{Regexp.escape(File.extname(path))}$/, ".#{asset_ext}")

      yield path if sitemap.find_resource_by_path(path)
    end

    # Generate body css classes based on the current path
    #
    # @return [String]
    def page_classes(options={})
      path = current_path.dup
      path << index_file if path.end_with?('/')
      path = ::Middleman::Util.strip_leading_slash(path)

      classes = []
      parts = path.split('.').first.split('/')
      parts.each_with_index { |path, i| classes << parts.first(i+1).join('_') }

      prefix = options[:numeric_prefix] || "x"
      classes.map do |c|
        # Replace weird class name characters
        c = c.gsub(/[^a-zA-Z0-9\-_]/, '-')

        # Class names can't start with a digit
        c = "#{prefix}#{c}" if c =~ /\A\d/
        c
      end.join(' ')
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
        if resource = sitemap.find_resource_by_destination_path(url_for(path))
          resource.url
        else
          path = File.join(prefix, path)
          if resource = sitemap.find_resource_by_path(path)
            resource.url
          else
            File.join(config[:http_prefix], path)
          end
        end
      end
    end

    # Given a source path (referenced either absolutely or relatively)
    # or a Resource, this will produce the nice URL configured for that
    # path, respecting :relative_links, directory indexes, etc.
    def url_for(path_or_resource, options={})
      ::Middleman::Util.url_for(self, path_or_resource, options)
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
