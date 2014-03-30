require 'tilt'
require 'active_support/core_ext/string/output_safety'

module Middleman

  class FileRenderer

    def self.cache
      @_cache ||= ::Tilt::Cache.new
    end

    delegate :cache, :to => :"self.class"

    def initialize(app, path)
      @app = app
      @path = path.to_s
    end

    # Render an on-disk file. Used for everything, including layouts.
    #
    # @param [Hash] locs
    # @param [Hash] opts
    # @param [Class] context
    # @return [String]
    def render(locs = {}, opts = {}, context, &block)
      path = @path.dup

      # Detect the remdering engine from the extension
      extension = File.extname(path)
      engine = extension[1..-1].to_sym

      # Store last engine for later (could be inside nested renders)
      context.current_engine, engine_was = engine, context.current_engine

      # Save current buffer for later
      _buf_was = context.save_buffer

      # Read from disk or cache the contents of the file
      body = if opts[:template_body]
        opts.delete(:template_body)
      else
        get_template_data_for_file
      end

      # Merge per-extension options from config
      extension = File.extname(path)
      options = opts.dup.merge(options_for_ext(extension))
      options[:outvar] ||= '@_out_buf'
      options.delete(:layout)

      # Overwrite with frontmatter options
      options = options.deep_merge(options[:renderer_options]) if options[:renderer_options]

      template_class = ::Tilt[path]
      # Allow hooks to manipulate the template before render
      @app.class.callbacks_for_hook(:before_render).each do |callback|
        newbody = callback.call(body, path, locs, template_class)
        body = newbody if newbody # Allow the callback to return nil to skip it
      end

      # Read compiled template from disk or cache
      template = cache.fetch(:compiled_template, extension, options, body) do
       ::Tilt.new(path, 1, options) { body }
      end

      # Render using Tilt
      content = template.render(context, locs, &block)

      # Allow hooks to manipulate the result after render
      @app.class.callbacks_for_hook(:after_render).each do |callback|
        content = callback.call(content, path, locs, template_class)
      end

      output = ::ActiveSupport::SafeBuffer.new ''
      output.safe_concat content
      output
    ensure
      # Reset stored buffer
      context.restore_buffer(_buf_was)
      context.current_engine = engine_was
    end

    # Get the template data from a path
    # @param [String] path
    # @return [String]
    def get_template_data_for_file
      if @app.extensions[:front_matter]
        @app.extensions[:front_matter].template_data_for_file(@path)
      else
        File.read(File.expand_path(@path, source_dir))
      end
    end

  protected

    # Get a hash of configuration options for a given file extension, from
    # config.rb
    #
    # @param [String] ext
    # @return [Hash]
    def options_for_ext(ext)
      # Read options for extension from config/Tilt or cache
      cache.fetch(:options_for_ext, ext) do
        options = {}

        # Find all the engines which handle this extension in tilt. Look for
        # config variables of that name and merge it
        extension_class = ::Tilt[ext]
        ::Tilt.mappings.each do |mapping_ext, engines|
          next unless engines.include? extension_class
          engine_options = @app.config[mapping_ext.to_sym] || {}
          options.merge!(engine_options)
        end

        options
      end
    end
  end
end
