require 'middleman-core/file_renderer'
require 'middleman-core/template_renderer'

# rubocop:disable UnderscorePrefixedVariableName
module Middleman
  class TemplateContext
    attr_reader :app
    attr_accessor :current_engine

    delegate :config, :logger, :sitemap, :build?, :development?, :data, :extensions, :source_dir, :root, to: :app

    def initialize(app, locs={}, opts={})
      @app = app
      @current_locs = locs
      @current_opts = opts
    end

    def save_buffer
      @_out_buf, _buf_was = '', @_out_buf
      _buf_was
    end

    # rubocop:disable TrivialAccessors
    def restore_buffer(_buf_was)
      @_out_buf = _buf_was
    end

    # Allow layouts to be wrapped in the contents of other layouts
    # @param [String, Symbol] layout_name
    # @return [void]
    def wrap_layout(layout_name, &block)
      # Save current buffer for later
      _buf_was = save_buffer

      layout_path = ::Middleman::TemplateRenderer.locate_layout(@app, layout_name, current_engine)

      extension = File.extname(layout_path)
      engine = extension[1..-1].to_sym

      # Store last engine for later (could be inside nested renders)
      self.current_engine, engine_was = engine, current_engine

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
    # @param [String, Symbol] data
    # @param [Hash] options
    # @return [String]
    def render(_, data, options={}, &block)
      data = data.to_s

      locals = options[:locals]

      found_partial = false
      resolve_opts = { try_without_underscore: true }

      # If the path is known to the sitemap
      if resource = sitemap.find_resource_by_path(current_path)
        current_dir = File.dirname(resource.source_file)
        resolve_opts[:preferred_engine] = File.extname(resource.source_file)[1..-1].to_sym

        # Look for partials relative to the current path
        relative_dir = File.join(current_dir.sub(%r{^#{Regexp.escape(source_dir)}/?}, ''), data)

        found_partial = ::Middleman::TemplateRenderer.resolve_template(@app, relative_dir, resolve_opts)
      end

      unless found_partial
        partials_path = File.join(@app.config[:partials_dir], data)
        found_partial = ::Middleman::TemplateRenderer.resolve_template(@app, partials_path, resolve_opts)
      end

      raise ::Middleman::TemplateRenderer::TemplateNotFound, "Could not locate partial: #{data}" unless found_partial

      file_renderer = ::Middleman::FileRenderer.new(@app, found_partial)
      file_renderer.render(locals, options, self, &block)
    end
  end
end
