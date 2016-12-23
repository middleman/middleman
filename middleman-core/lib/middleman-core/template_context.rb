require 'pathname'
require 'middleman-core/file_renderer'
require 'middleman-core/template_renderer'
require 'middleman-core/contracts'

module Middleman
  # The TemplateContext Class
  #
  # A clean context, separate from Application, in which templates can be executed.
  # All helper methods and values available in a template, but be accessible here.
  # Also implements two helpers: wrap_layout & render (used by padrino's partial method).
  # A new context is created for each render of a path, but that context is shared through
  # the request, passed from template, to layouts and partials.
  class TemplateContext
    extend Forwardable
    include Contracts

    # Allow templates to directly access the current app instance.
    # @return [Middleman::Application]
    attr_reader :app

    # Required for Padrino's rendering
    attr_accessor :current_engine

    # Shorthand references to global values on the app instance.
    def_delegators :@app, :config, :logger, :sitemap, :server?, :build?, :environment?, :environment, :data, :extensions, :root, :development?, :production?

    # Initialize a context with the current app and predefined locals and options hashes.
    #
    # @param [Middleman::Application] app
    # @param [Hash] locs
    # @param [Hash] opts
    def initialize(app, locs={}, opts={})
      @app = app
      @locs = locs
      @opts = opts
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
      layout_file = ::Middleman::TemplateRenderer.locate_layout(@app, layout_name, current_engine)

      # Get the layout engine
      extension = File.extname(layout_file[:relative_path])
      engine = extension[1..-1].to_sym

      # Store last engine for later (could be inside nested renders)
      self.current_engine = engine
      engine_was = current_engine

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
      concat_safe_content render_file(layout_file, @locs, @opts) { content }
    ensure
      # Reset engine back to template's value, regardless of success
      self.current_engine = engine_was
    end

    # Sinatra/Padrino compatible render method signature referenced by some view
    # helpers. Especially partials.
    #
    # @param [String, Symbol] name The partial to render.
    # @param [Hash] options
    # @param [Proc] block A block will be evaluated to return internal contents.
    # @return [String]
    Contract Any, Or[Symbol, String], Hash => String, Maybe[Proc] => String
    def render(_, name, options={}, &block)
      name = name.to_s

      partial_file = locate_partial(name, false) || locate_partial(name, true)

      raise ::Middleman::TemplateRenderer::TemplateNotFound, "Could not locate partial: #{name}" unless partial_file

      source_path = sitemap.file_to_path(partial_file)
      r = sitemap.find_resource_by_path(source_path)

      if (r && !r.template?) || (Tilt[partial_file[:full_path]].nil? && partial_file[:full_path].exist?)
        partial_file.read
      else
        opts = options.dup
        locs = opts.delete(:locals)

        render_file(partial_file, locs, opts, &block)
      end
    end

    # Locate a partial relative to the current path or the source dir, given a partial's path.
    #
    # @api private
    # @param [String] partial_path
    # @return [String]
    Contract String, Maybe[Bool] => Maybe[IsA['Middleman::SourceFile']]
    def locate_partial(partial_path, try_static=true)
      partial_file = nil
      lookup_stack = []
      non_root     = partial_path.to_s.sub(/^\//, '')
      non_root_no_underscore = non_root.sub(/^_/, '').sub(/\/_/, '/')

      if resource = current_resource
        current_dir  = resource.file_descriptor[:relative_path].dirname
        relative_dir = current_dir + Pathname(non_root)
        relative_dir_no_underscore = current_dir + Pathname(non_root_no_underscore)
      end

      if relative_dir
        lookup_stack.push [relative_dir.to_s,
                           { preferred_engine: resource.file_descriptor[:relative_path]
                             .extname[1..-1].to_sym }]
      end
      lookup_stack.push [non_root]
      lookup_stack.push [non_root,
                         { try_static: try_static }]
      if relative_dir_no_underscore
        lookup_stack.push [relative_dir_no_underscore.to_s,
                           { try_static: try_static }]
      end
      lookup_stack.push [non_root_no_underscore,
                         { try_static: try_static }]

      lookup_stack.each do |args|
        partial_file = ::Middleman::TemplateRenderer.resolve_template(@app, *args)
        break if partial_file
      end

      partial_file
    end

    def current_path
      @locs[:current_path]
    end

    # Get the resource object for the current path
    # @return [Middleman::Sitemap::Resource]
    def current_resource
      return nil unless current_path
      sitemap.find_resource_by_destination_path(current_path)
    end
    alias current_page current_resource

    protected

    # Render a path with locs, opts and contents block.
    #
    # @api private
    # @param [Middleman::SourceFile] file The file.
    # @param [Hash] locs Template locals.
    # @param [Hash] opts Template options.
    # @param [Proc] block A block will be evaluated to return internal contents.
    # @return [String] The resulting content string.
    Contract IsA['Middleman::SourceFile'], Hash, Hash, Maybe[Proc] => String
    def render_file(file, locs, opts, &block)
      _render_with_all_renderers(file[:relative_path].to_s, locs, self, opts, &block)
    end

    Contract String, Hash, Any, Hash, Maybe[Proc] => String
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
  end
end
