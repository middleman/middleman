require 'middleman-core/file_renderer'
require 'middleman-core/template_renderer'

module Middleman
  class TemplateContext
    attr_reader :app
    attr_accessor :current_engine, :current_path

    delegate :config, :logger, :sitemap, :build?, :development?, :data, :extensions, :source_dir, :root, :to => :app

    def initialize(app, locs={}, opts={})
      @app = app
      @current_locs = locs
      @current_opts = opts
    end

    def save_buffer
      @_out_buf, _buf_was = '', @_out_buf
      _buf_was
    end

    def restore_buffer(_buf_was)
      @_out_buf = _buf_was
    end

    # Allow layouts to be wrapped in the contents of other layouts
    # @param [String, Symbol] layout_name
    # @return [void]
    def wrap_layout(layout_name, &block)
      # Save current buffer for later
      _buf_was = save_buffer

      layout_path = ::Middleman::TemplateRenderer.locate_layout(@app, layout_name, self.current_engine)

      extension = File.extname(layout_path)
      engine = extension[1..-1].to_sym

      # Store last engine for later (could be inside nested renders)
      self.current_engine, engine_was = engine, self.current_engine

      begin
        content = if block_given?
          capture_html(&block)
        else
          ''
        end
      ensure
        # Reset stored buffer
        restore_buffer(_buf_was)
      end

      file_renderer = ::Middleman::FileRenderer.new(@app, layout_path)
      concat_safe_content file_renderer.render(@current_locs || {}, @current_opts || {}, self) { content }
    ensure
      self.current_engine = engine_was
    end

    # Sinatra/Padrino compatible render method signature referenced by some view
    # helpers. Especially partials.
    #
    # @param [String, Symbol] engine
    # @param [String, Symbol] data
    # @param [Hash] options
    # @return [String]
    def render(engine, data, options={}, &block)
      data = data.to_s

      locals = options[:locals]

      found_partial = false
      engine        = nil

      # If the path is known to the sitemap
      if resource = sitemap.find_resource_by_path(current_path)
        current_dir = File.dirname(resource.source_file)
        engine = File.extname(resource.source_file)[1..-1].to_sym

        # Look for partials relative to the current path
        relative_dir = File.join(current_dir.sub(%r{^#{Regexp.escape(self.source_dir)}/?}, ''), data)

        # Try to use the current engine first
        found_partial, found_engine = ::Middleman::TemplateRenderer.resolve_template(@app, relative_dir, :preferred_engine => engine, :try_without_underscore => true)

        # Fall back to any engine available
        if !found_partial
          found_partial, found_engine = ::Middleman::TemplateRenderer.resolve_template(@app, relative_dir, :try_without_underscore => true)
        end
      end

      # Look in the partials_dir for the partial with the current engine
      partials_path = File.join(config[:partials_dir], data)
      if !found_partial && !engine.nil?
        found_partial, found_engine = ::Middleman::TemplateRenderer.resolve_template(@app, partials_path, :preferred_engine => engine, :try_without_underscore => true)
      end

      # Look in the root with any engine
      if !found_partial
        found_partial, found_engine = ::Middleman::TemplateRenderer.resolve_template(@app, partials_path, :try_without_underscore => true)
      end

      # Render the partial if found, otherwide throw exception
      if found_partial
        file_renderer = ::Middleman::FileRenderer.new(@app, found_partial)
        file_renderer.render(locals, options, self, &block)
      else
        raise ::Middleman::TemplateRenderer::TemplateNotFound, "Could not locate partial: #{data}"
      end
    end
  end
end
