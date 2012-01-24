require 'padrino-core/support_lite' unless defined?(SupportLite)

module Padrino
  ##
  # Padrino enhances the Sinatra 'render' method to have support for
  # automatic template engine detection, enhanced layout functionality,
  # locale enabled rendering, among other features.
  #
  module Rendering
    ##
    # Exception responsible for when an expected template did not exist.
    #
    class TemplateNotFound < RuntimeError
    end

    ##
    # This is an array of file patterns to ignore. If your editor add a
    # suffix during editing to your files please add it like:
    #
    # @example
    #   Padrino::Rendering::IGNORE_FILE_PATTERN << /~$/
    #
    IGNORE_FILE_PATTERN = [
      /~$/ # This is for Gedit
    ] unless defined?(IGNORE_FILE_PATTERN)

    ##
    # Default rendering options used in the #render-method.
    #
    DEFAULT_RENDERING_OPTIONS = { :strict_format => false, :raise_exceptions => true } unless defined?(DEFAULT_RENDERING_OPTIONS)

    class << self
      ##
      # Main class that register this extension.
      #
      def registered(app)
        app.send(:include, InstanceMethods)
        app.extend(ClassMethods)
      end
      alias :included :registered
    end

    ##
    # Class methods responsible for rendering templates as part of a request.
    #
    module ClassMethods
      ##
      # Use layout like rails does or if a block given then like sinatra.
      # If used without a block, sets the current layout for the route.
      #
      # By default, searches in your:
      #
      # +app+/+views+/+layouts+/+application+.(+haml+|+erb+|+xxx+)
      # +app+/+views+/+layout_name+.(+haml+|+erb+|+xxx+)
      #
      # If you define +layout+ :+custom+ then searches for your layouts in
      # +app+/+views+/+layouts+/+custom+.(+haml+|+erb+|+xxx+)
      # +app+/+views+/+custom+.(+haml+|+erb+|+xxx+)
      #
      # @param [Symbol] name (:layout)
      #   The layout to use.
      #
      # @yield []
      #
      def layout(name=:layout, &block)
        return super(name, &block) if block_given?
        @layout = name
      end

      ##
      # Returns the cached template file to render for a given url, content_type and locale.
      #
      # @param [Array<template_path, content_type, locale>] render_options
      #
      def fetch_template_file(render_options)
        (@_cached_templates ||= {})[render_options]
      end

      ##
      # Caches the template file for the given rendering options
      #
      # @param [String] template_file
      #   The path of the template file.
      #
      # @param [Array<template_path, content_type, locale>] render_options
      #
      def cache_template_file!(template_file, render_options)
        (@_cached_templates ||= {})[render_options] = template_file || []
      end

      ##
      # Returns the cached layout path.
      #
      # @param [Symbol, nil] given_layout
      #   The requested layout.
      #
      def fetch_layout_path(given_layout=nil)
        layout_name = given_layout || @layout || :application
        @_cached_layout ||= {}
        cached_layout_path = @_cached_layout[layout_name]
        return cached_layout_path if cached_layout_path
        has_layout_at_root = Dir["#{views}/#{layout_name}.*"].any?
        layout_path = has_layout_at_root ? layout_name.to_sym : File.join('layouts', layout_name.to_s).to_sym
        @_cached_layout[layout_name] = layout_path unless reload_templates?
        layout_path
      end
    end

    # Instance methods that allow enhanced rendering to function properly in Padrino.
    module InstanceMethods
      attr_reader :current_engine

      ##
      # Get/Set the content_type
      #
      # @param [String, nil] type
      #   The Content-Type to use.
      #
      # @param [Symbol, nil] type.
      #   Look and parse the given symbol to the matched Content-Type.
      #
      # @param [Hash] params
      #   Additional params to append to the Content-Type.
      #
      # @example
      #   case content_type
      #     when :js then do_some
      #     when :css then do_another
      #   end
      #
      #   content_type :js
      #   # => set the response with 'application/javascript' Content-Type
      #   content_type 'text/html'
      #
      #   # => set directly the Content-Type to 'text/html'
      #
      def content_type(type=nil, params={})
        unless type.nil?
          super(type, params)
          @_content_type = type
        end
        @_content_type
      end

      private
        ##
        # Enhancing Sinatra render functionality for:
        #
        # * Using layout similar to rails
        # * Use render 'path/to/my/template'   (without symbols)
        # * Use render 'path/to/my/template'   (with engine lookup)
        # * Use render 'path/to/template.haml' (with explicit engine lookup)
        # * Use render 'path/to/template', :layout => false
        # * Use render 'path/to/template', :layout => false, :engine => 'haml'
        # * Use render { :a => 1, :b => 2, :c => 3 } # => return a json string
        #
        def render(engine, data=nil, options={}, locals={}, &block)
          # If engine is a hash then render data converted to json
          content_type(:json, :charset => 'utf-8') and return engine.to_json if engine.is_a?(Hash)

          # If engine is nil, ignore engine parameter and shift up all arguments
          # render nil, "index", { :layout => true }, { :localvar => "foo" }
          engine, data, options = data, options, locals if engine.nil? && data

          # Data is a hash of options when no engine isn't explicit
          # render "index", { :layout => true }, { :localvar => "foo" }
          # Data is options, and options is locals in this case
          data, options, locals = nil, data, options if data.is_a?(Hash)

          # If data is unassigned then this is a likely a template to be resolved
          # This means that no engine was explicitly defined
          data, engine = *resolve_template(engine, options.dup) if data.nil?

          # Setup root
          root = settings.respond_to?(:root) ? settings.root : ""

          # Use @layout if it exists
          options[:layout] = @layout if options[:layout].nil?

          # Resolve layouts similar to in Rails
          if (options[:layout].nil? || options[:layout] == true) && !settings.templates.has_key?(:layout)
            layout_path, layout_engine = *resolved_layout
            options[:layout] = layout_path || false # We need to force layout false so sinatra don't try to render it
            options[:layout] = false unless layout_engine == engine # TODO allow different layout engine
            options[:layout_engine] = layout_engine || engine if options[:layout]
          elsif options[:layout].present?
            options[:layout] = settings.fetch_layout_path(options[:layout] || @layout)
          end

          # Cleanup the template
          @current_engine, engine_was = engine, @current_engine
          @_out_buf,  _buf_was = "", @_out_buf

          # Pass arguments to Sinatra render method
          super(engine, data, options.dup, locals, &block)
        ensure
          @current_engine = engine_was
          @_out_buf = _buf_was
        end

        ##
        # Returns the located layout tuple to be used for the rendered template
        # (if available).
        #
        # @example
        #   resolve_layout
        #   # => ["/layouts/custom", :erb]
        #   # => [nil, nil]
        #
        def resolved_layout
          located_layout = resolve_template(settings.fetch_layout_path, :raise_exceptions => false, :strict_format => true)
          located_layout ? located_layout : [nil, nil]
        end

        ##
        # Returns the template path and engine that match content_type (if present),
        # I18n.locale.
        #
        # @param [String] template_path
        #   The path of the template.
        #
        # @param [Hash] options
        #   Additional options.
        #
        # @option options [Boolean] :strict_format (false)
        #   The resolved template must match the content_type of the request.
        #
        # @option options [Boolean] :raise_exceptions (false)
        #   Raises a {TemplateNotFound} exception if the template cannot be located.
        #
        # @return [Array<Symbol, Symbol>]
        #   The path and format of the template.
        #
        # @raise [TemplateNotFound]
        #   The template could not be found.
        #
        # @example
        #   get "/foo", :provides => [:html, :js] do; render 'path/to/foo'; end
        #   # If you request "/foo.js" with I18n.locale == :ru => [:"/path/to/foo.ru.js", :erb]
        #   # If you request "/foo" with I18n.locale == :de => [:"/path/to/foo.de.haml", :haml]
        #
        def resolve_template(template_path, options={})
          began_at = Time.now
          # Fetch cached template for rendering options
          template_path = template_path.to_s[0] == ?/ ? template_path.to_s : "/#{template_path}"
          rendering_options = [template_path, content_type, locale]
          cached_template = settings.fetch_template_file(rendering_options)
          if cached_template
            logger.debug :cached, began_at, cached_template[0] if settings.logging? && defined?(logger)
            return cached_template
          end

          # Resolve view path and options
          options.reverse_merge!(DEFAULT_RENDERING_OPTIONS)
          view_path = options.delete(:views) || settings.views || "./views"
          target_extension = File.extname(template_path)[1..-1] || "none" # explicit template extension
          template_path = template_path.chomp(".#{target_extension}")

          # Generate potential template candidates
          templates = Dir[File.join(view_path, template_path) + ".*"].map do |file|
            template_engine = File.extname(file)[1..-1].to_sym # retrieves engine extension
            template_file   = file.sub(view_path, '').chomp(".#{template_engine}").to_sym # retrieves template filename
            [template_file, template_engine] unless IGNORE_FILE_PATTERN.any? { |pattern| template_engine.to_s =~ pattern }
          end

          # Check if we have a simple content type
          simple_content_type = [:html, :plain].include?(content_type)

          # Resolve final template to render
          located_template =
            templates.find { |file, e| file.to_s == "#{template_path}.#{locale}.#{content_type}" } ||
            templates.find { |file, e| file.to_s == "#{template_path}.#{locale}" && simple_content_type } ||
            templates.find { |file, e| File.extname(file.to_s) == ".#{target_extension}" or e.to_s == target_extension.to_s } ||
            templates.find { |file, e| file.to_s == "#{template_path}.#{content_type}" } ||
            templates.find { |file, e| file.to_s == "#{template_path}" && simple_content_type } ||
            (!options[:strict_format] && templates.first) # If not strict, fall back to the first located template

          raise TemplateNotFound, "Template '#{template_path}' not found in '#{view_path}'!"  if !located_template && options[:raise_exceptions]
          settings.cache_template_file!(located_template, rendering_options) unless settings.reload_templates?
          logger.debug :template, began_at, located_template[0] if located_template && settings.logging? && defined?(logger)
          located_template
        end

        ##
        # Return the I18n.locale if I18n is defined.
        #
        def locale
          I18n.locale if defined?(I18n)
        end
    end # InstanceMethods
  end # Rendering
end # Padrino
