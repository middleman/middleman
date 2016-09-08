require 'tilt'
require 'active_support/core_ext/string/output_safety'
require 'middleman-core/template_context'
require 'middleman-core/file_renderer'
require 'middleman-core/contracts'

module Middleman
  class TemplateRenderer
    extend Forwardable
    include Contracts

    class Cache
      def initialize
        @cache = {}
      end

      def fetch(*key)
        @cache[key] = yield unless @cache.key?(key)
        @cache[key]
      end

      def clear
        @cache = {}
      end
    end

    def self.cache
      @_cache ||= Cache.new
    end

    # Find a layout on-disk, optionally using a specific engine
    # @param [String] name
    # @param [Symbol] preferred_engine
    # @return [String]
    Contract IsA['Middleman::Application'], Or[String, Symbol], Symbol => Maybe[IsA['Middleman::SourceFile']]
    def self.locate_layout(app, name, preferred_engine=nil)
      resolve_opts = {}
      resolve_opts[:preferred_engine] = preferred_engine unless preferred_engine.nil?

      # Check layouts folder
      layout_file = resolve_template(app, File.join(app.config[:layouts_dir], name.to_s), resolve_opts)

      # If we didn't find it, check root
      layout_file = resolve_template(app, name, resolve_opts) unless layout_file

      # Return the path
      layout_file
    end

    # Find a template on disk given a output path
    # @param [String] request_path
    # @option options [Boolean] :preferred_engine If set, try this engine first, then fall back to any engine.
    # @return [String, Boolean] Either the path to the template, or false
    Contract IsA['Middleman::Application'], Or[Symbol, String], Maybe[Hash] => Maybe[IsA['Middleman::SourceFile']]
    def self.resolve_template(app, request_path, options={})
      # Find the path by searching
      relative_path = Util.strip_leading_slash(request_path.to_s)

      # By default, any engine will do
      preferred_engines = []

      # If we're specifically looking for a preferred engine
      if options.key?(:preferred_engine)
        extension_class = ::Middleman::Util.tilt_class(options[:preferred_engine])

        # Get a list of extensions for a preferred engine
        preferred_engines += ::Tilt.default_mapping.extensions_for(extension_class)
      end

      preferred_engines << '*'
      preferred_engines << nil if options[:try_static]

      found_template = nil

      preferred_engines.each do |preferred_engine|
        path_with_ext = relative_path.dup
        path_with_ext << ('.' + preferred_engine) unless preferred_engine.nil?

        globbing = preferred_engine == '*'

        # Cache lookups in build mode only
        file = if app.build?
          cache.fetch(path_with_ext, preferred_engine) do
            app.files.find(:source, path_with_ext, globbing)
          end
        else
          app.files.find(:source, path_with_ext, globbing)
        end

        found_template = file if file && (preferred_engine.nil? || ::Middleman::Util.tilt_class(file[:full_path].to_s))
        break if found_template
      end

      # If we found one, return it
      found_template
    end

    # Custom error class for handling
    class TemplateNotFound < RuntimeError; end

    def initialize(app, path)
      @app = app
      @path = path
    end

    # Render a template, with layout, given a path
    #
    # @param [Hash] locs
    # @param [Hash] opts
    # @return [String]
    Contract Hash, Hash => String
    def render(locs={}, opts={}, &block)
      path = @path.dup
      locals = locs.dup.freeze
      options = opts.dup

      extension = File.extname(path)
      engine = extension[1..-1].to_sym

      if defined?(::I18n)
        old_locale = ::I18n.locale
        ::I18n.locale = options[:locale] if options[:locale]

        # Backwards compat
        ::I18n.locale = options[:lang] if options[:lang]
      end

      # Sandboxed class for template eval
      context = @app.template_context_class.new(@app, locals, options)

      # Add extension helpers to context.
      @app.extensions.add_exposed_to_context(context)

      locals.each do |k, _|
        next unless context.respond_to?(k) && ![:current_path, :paginate, :page_articles, :blog_controller, :lang, :locale].include?(k.to_sym)

        msg = "Template local `#{k}` tried to overwrite an existing context value. Please rename the key when passing to `locals`"

        if @app.build?
          throw msg
        else
          @app.logger.error(msg)
        end
      end

      content = ::Middleman::Util.instrument 'builder.output.resource.render-template', path: File.basename(path) do
        _render_with_all_renderers(path, locals, context, options, &block)
      end

      # If we need a layout and have a layout, use it
      layout_file = fetch_layout(engine, options)
      if layout_file
        content = if layout_file = fetch_layout(engine, options)
          layout_renderer = ::Middleman::FileRenderer.new(@app, layout_file[:relative_path].to_s)

          ::Middleman::Util.instrument 'builder.output.resource.render-layout', path: File.basename(layout_file[:relative_path].to_s) do
            layout_renderer.render(locals, options, context) { content }
          end
        else
          content
        end
      end

      # Return result
      content
    ensure
      # Pop all the saved variables from earlier as we may be returning to a
      # previous render (layouts, partials, nested layouts).
      ::I18n.locale = old_locale if defined?(::I18n)
    end

    protected

    def _render_with_all_renderers(path, locs, context, opts, &block)
      # Keep rendering template until we've used up all extensions. This
      # handles cases like `style.css.sass.erb`
      content = nil

      while ::Middleman::Util.tilt_class(path)
        begin
          opts[:template_body] = content if content

          content_renderer = ::Middleman::FileRenderer.new(@app, path)
          content = content_renderer.render(locs, opts, context, &block)

          path = File.basename(path, File.extname(path))
        rescue LocalJumpError
          raise "Tried to render a layout (calls yield) at #{path} like it was a template. Non-default layouts need to be in #{@app.config[:source]}/#{@app.config[:layouts_dir]}."
        end
      end

      content
    end

    # Find a layout for a given engine
    #
    # @param [Symbol] engine
    # @param [Hash] opts
    # @return [String, Boolean]
    Contract Symbol, Hash => Maybe[IsA['Middleman::SourceFile']]
    def fetch_layout(engine, opts)
      # The layout name comes from either the system default or the options
      local_layout = opts.key?(:layout) ? opts[:layout] : @app.config[:layout]
      return unless local_layout

      # Look for engine-specific options
      engine_options = @app.config.respond_to?(engine) ? @app.config.send(engine) : {}

      # The engine for the layout can be set in options, engine_options or passed
      # into this method
      layout_engine = if opts.key?(:layout_engine)
        opts[:layout_engine]
      elsif engine_options.key?(:layout_engine)
        engine_options[:layout_engine]
      else
        engine
      end

      # Automatic mode
      if local_layout == :_auto_layout
        # Look for :layout of any extension
        # If found, use it. If not, continue
        locate_layout(:layout, layout_engine)
      elsif layout_file = locate_layout(local_layout, layout_engine)
        # Look for specific layout
        # If found, use it. If not, error.

        layout_file
      else
        raise ::Middleman::TemplateRenderer::TemplateNotFound, "Could not locate layout: #{local_layout}"
      end
    end

    # Find a layout on-disk, optionally using a specific engine
    # @param [String] name
    # @param [Symbol] preferred_engine
    # @return [String]
    Contract Or[String, Symbol], Symbol => Maybe[IsA['Middleman::SourceFile']]
    def locate_layout(name, preferred_engine=nil)
      self.class.locate_layout(@app, name, preferred_engine)
    end

    # Find a template on disk given a output path
    # @param [String] request_path
    # @param [Hash] options
    # @return [Array<String, Symbol>, Boolean]
    Contract String, Hash => ArrayOf[Or[String, Symbol]]
    def resolve_template(request_path, options={})
      self.class.resolve_template(@app, request_path, options)
    end
  end
end
