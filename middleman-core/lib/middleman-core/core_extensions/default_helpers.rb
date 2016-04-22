require 'padrino-helpers'
require 'middleman-core/contracts'

# Don't fail on invalid locale, that's not what our current
# users expect.
::I18n.enforce_available_locales = false

class Padrino::Helpers::OutputHelpers::ErbHandler
  # Force Erb capture not to use safebuffer
  def capture_from_template(*args, &block)
    self.output_buffer = ''
    buf_was = output_buffer
    raw = yield(*args)
    captured = template.instance_variable_get(:@_out_buf)
    self.output_buffer = buf_was
    engine_matches?(block) && !captured.empty? ? captured : raw
  end
end

class Middleman::CoreExtensions::DefaultHelpers < ::Middleman::Extension
  define_setting :relative_links, false, 'Whether to generate relative links instead of absolute ones'

  def initialize(app, options_hash={}, &block)
    super

    require 'active_support/core_ext/object/to_query'

    ::Middleman::TemplateContext.send :include, ::Padrino::Helpers::OutputHelpers
    ::Middleman::TemplateContext.send :include, ::Padrino::Helpers::TagHelpers
    ::Middleman::TemplateContext.send :include, ::Padrino::Helpers::AssetTagHelpers
    ::Middleman::TemplateContext.send :include, ::Padrino::Helpers::FormHelpers
    ::Middleman::TemplateContext.send :include, ::Padrino::Helpers::FormatHelpers
    ::Middleman::TemplateContext.send :include, ::Padrino::Helpers::RenderHelpers
    ::Middleman::TemplateContext.send :include, ::Padrino::Helpers::NumberHelpers
    # ::Middleman::TemplateContext.send :include, ::Padrino::Helpers::TranslationHelpers
  end

  # The helpers
  helpers do
    # Make all block content html_safe
    def content_tag(name, content=nil, options=nil, &block)
      # safe_content_tag(name, content, options, &block)
      if block_given?
        options = content if content.is_a?(Hash)
        content = capture_html(&block)
      end

      options    = parse_data_options(name, options)
      attributes = tag_attributes(options)
      output = ActiveSupport::SafeBuffer.new
      output.safe_concat "<#{name}#{attributes}>"

      if content.respond_to?(:each) && !content.is_a?(String)
        content.each do |c|
          output.safe_concat c
          output.safe_concat ::Padrino::Helpers::TagHelpers::NEWLINE
        end
      else
        output.safe_concat content.to_s
      end
      output.safe_concat "</#{name}>"

      block_is_template?(block) ? concat_content(output) : output
    end

    def capture_html(*args, &block)
      result = if handler = auto_find_proper_handler(&block)
        handler.capture_from_template(*args, &block)
      else
        yield(*args)
      end

      ::ActiveSupport::SafeBuffer.new.safe_concat(result)
    end

    def auto_find_proper_handler(&block)
      if block_given?
        engine = File.extname(block.source_location[0])[1..-1].to_sym
        ::Padrino::Helpers::OutputHelpers.handlers.select { |e, _| e == engine }.values.map { |h| h.new(self) }.find { |h| h.engine_matches?(block) }
      else
        find_proper_handler
      end
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

    # Override helper to add `relative` opt-out.
    def stylesheet_link_tag(*sources)
      options = {
        rel: 'stylesheet'
      }.update(sources.extract_options!.symbolize_keys)

      path_options = {}
      path_options[:relative] = options.delete(:relative) if options.key?(:relative)

      sources.flatten.reduce(::ActiveSupport::SafeBuffer.new) do |all, source|
        all << tag(:link, {
          href: asset_path(:css, source, path_options)
        }.update(options))
      end
    end

    # Override helper to add `relative` opt-out.
    def javascript_include_tag(*sources)
      options = sources.extract_options!.symbolize_keys

      path_options = {}
      path_options[:relative] = options.delete(:relative) if options.key?(:relative)

      sources.flatten.reduce(::ActiveSupport::SafeBuffer.new) do |all, source|
        all << content_tag(:script, nil, {
          src: asset_path(:js, source, path_options)
        }.update(options))
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
        when :js
          config[:js_dir]
        when :css
          config[:css_dir]
        end
      end

      # If the basename of the request as no extension, assume we are serving a
      # directory and join index_file to the path.
      path = File.join(asset_dir, current_resource.path)
      path = path[0..-(File.extname(path).length + 1)] + ".#{asset_ext}"

      yield path if sitemap.find_resource_by_path(path)
    end

    # Generate body css classes based on the current path
    #
    # @return [String]
    def page_classes(path=current_path.dup, options={})
      if path.is_a? Hash
        options = path
        path = current_path.dup
      end

      path << index_file if path.end_with?('/')
      path = ::Middleman::Util.strip_leading_slash(path)

      classes = Set.new
      parts = path.split('.').first.split('/')
      parts.each_with_index { |_, i| classes << parts.first(i + 1).join('_') }

      prefix = options[:numeric_prefix] || 'x'
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
    # @param [Hash] options Data to pass through.
    # @return [String]
    def asset_path(kind, source, options={})
      options_with_resource = {}.merge!(options).merge!(current_resource: current_resource)
      ::Middleman::Util.asset_path(app, kind, source, options_with_resource)
    end

    # Get the URL of an asset given a type/prefix
    #
    # @param [String] path The path (such as "photo.jpg")
    # @param [String] prefix The type prefix (such as "images")
    # @param [Hash] options Additional options.
    # @return [String] The fully qualified asset url
    def asset_url(path, prefix='', options={})
      options_with_resource = {}.merge!(options).merge!(current_resource: current_resource)
      ::Middleman::Util.asset_url(app, path, prefix, options_with_resource)
    end

    # Given a source path (referenced either absolutely or relatively)
    # or a Resource, this will produce the nice URL configured for that
    # path, respecting :relative_links, directory indexes, etc.
    def url_for(path_or_resource, options={})
      options_with_resource = {}.merge!(options).merge!(current_resource: current_resource)
      ::Middleman::Util.url_for(app, path_or_resource, options_with_resource)
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
        raise ArgumentError, 'Too many arguments to link_to(url, options={}, &block)'
      end

      if url = args[url_arg_index]
        options = args[options_index] || {}
        raise ArgumentError, 'Options must be a hash' unless options.is_a?(Hash)

        # Transform the url through our magic url_for method
        args[url_arg_index] = url_for(url, options)

        # Cleanup before passing to Padrino
        options.except!(:relative, :current_resource, :find_resource, :query, :anchor, :fragment)
      end

      super(*args, &block)
    end

    # Modified Padrino form_for that uses Middleman's url_for
    # to transform the URL.
    def form_tag(url, options={}, &block)
      url = url_for(url, options)
      super
    end

    # Modified Padrino image_tag so that it finds the paths for srcset
    # using asset_path for the images listed in the srcset param
    def image_tag(path, params={})
      params.symbolize_keys!

      if params.key?(:srcset)
        images_sources = params[:srcset].split(',').map do |src_def|
          if src_def.include?('//')
            src_def
          else
            image_def, size_def = src_def.strip.split(/\s+/)
            asset_path(:images, image_def) + ' ' + size_def
          end
        end

        params[:srcset] = images_sources.join(', ')
      end

      super(path, params)
    end

    def partial(template, options={}, &block)
      including_parent_locals = {}
      including_parent_locals.merge!(@locs || {})
      including_parent_locals.merge!(options[:locals] || {})

      options[:locals] = including_parent_locals
      super(template, options, &block)
    end
  end
end
