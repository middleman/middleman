require 'pathname'
require 'middleman-core/file_renderer'
require 'middleman-core/template_renderer'

module Middleman
  # The TemplateContext Class
  #
  # A clean context, separate from Application, in which templates can be executed.
  # All helper methods and values available in a template, but be accessible here.
  # Also implements two helpers: wrap_layout & render (used by padrino's partial method).
  # A new context is created for each render of a path, but that context is shared through
  # the request, passed from template, to layouts and partials.
  class TemplateContext
    # Allow templates to directly access the current app instance.
    # @return [Middleman::Application]
    attr_reader :app

    # Required for Padrino's rendering
    attr_accessor :current_engine

    # Shorthand references to global values on the app instance.
    delegate :config, :logger, :sitemap, :server?, :build?, :environment?, :data, :extensions, :source_dir, :root, to: :app

    # Initialize a context with the current app and predefined locals and options hashes.
    #
    # @param [Middleman::Application] app
    # @param [Hash] locs
    # @param [Hash] opts
    def initialize(app, locs={}, opts={})
      @app = app
      @locs = locs.dup.freeze
      @opts = opts.dup.freeze
    end

    # Return the current buffer to the caller and clear the value internally.
    # Used when moving between templates when rendering layouts or partials.
    #
    # @api private
    # @return [String] The old buffer.
    def save_buffer
      @_out_buf, buf_was = '', @_out_buf
      buf_was
    end

    # Restore a previously saved buffer.
    #
    # @api private
    # @param [String] buf_was
    # @return [void]
    def restore_buffer(buf_was)
      @_out_buf = buf_was
    end

    # Allow layouts to be wrapped in the contents of other layouts.
    #
    # @param [String, Symbol] layout_name
    # @return [void]
    def wrap_layout(layout_name, &block)
      # Save current buffer for later
      buf_was = save_buffer

      # Find a layout for this file
      layout_path = ::Middleman::TemplateRenderer.locate_layout(@app, layout_name, current_engine)

      # Get the layout engine
      extension = File.extname(layout_path)
      engine = extension[1..-1].to_sym

      # Store last engine for later (could be inside nested renders)
      self.current_engine, engine_was = engine, current_engine

      # By default, no content is captured
      content = ''

      # Attempt to capture HTML from block
      begin
        content = capture_html(&block) if block_given?
      ensure
        # Reset stored buffer, regardless of success
        restore_buffer(buf_was)
      end
      # Render the layout, with the contents of the block inside.
      concat_safe_content render_file(layout_path, @locs, @opts) { content }
    ensure
      # Reset engine back to template's value, regardless of success
      self.current_engine = engine_was
    end

    # Sinatra/Padrino compatible render method signature referenced by some view
    # helpers. Especially partials.
    #
    # @param [] _ Unused parameter.
    # @param [String, Symbol] name The partial to render.
    # @param [Hash] options
    # @return [String]
    def render(_, name, options={}, &block)
      name = name.to_s

      partial_path = locate_partial_relative(name) || locate_partial_in_partials_dir(name)

      raise ::Middleman::TemplateRenderer::TemplateNotFound, "Could not locate partial: #{name}" unless partial_path

      opts = options.dup
      locs = opts.delete(:locals)

      render_file(partial_path, locs.freeze, opts.freeze, &block)
    end

    protected

    # Locate a partial reltive to the current path, given a name.
    #
    # @api private
    # @param [String] name
    # @return [String]
    def locate_partial_relative(name)
      return unless resource = sitemap.find_resource_by_path(current_path)

      # Look for partials relative to the current path
      current_dir = File.dirname(resource.source_file)
      relative_dir = File.join(current_dir.sub(%r{^#{Regexp.escape(source_dir)}/?}, ''), name)

      ::Middleman::TemplateRenderer.resolve_template(
        @app,
        relative_dir,
        try_without_underscore: true,
        preferred_engine: File.extname(resource.source_file)[1..-1].to_sym
      )
    end

    # Locate a partial reltive to the partials dir, given a name.
    #
    # @api private
    # @param [String] name
    # @return [String]
    def locate_partial_in_partials_dir(name)
      partials_path = File.join(@app.config[:partials_dir], name)
      ::Middleman::TemplateRenderer.resolve_template(
        @app,
        partials_path,
        try_without_underscore: true
      )
    end

    # Render a path with locs, opts and contents block.
    #
    # @api private
    # @param [String] path The file path.
    # @param [Hash] locs Template locals.
    # @param [Hash] opts Template options.
    # @param [Proc] block A block will be evaluated to return internal contents.
    # @return [String] The resulting content string.
    def render_file(path, locs, opts, &block)
      file_renderer = ::Middleman::FileRenderer.new(@app, path)
      file_renderer.render(locs, opts, self, &block)
    end
  end
end
