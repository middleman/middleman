# Use Rack::Test for inspecting a running server for output
require "rack"
require "rack/test"

require 'find'

module Middleman
  class Builder

    # Sort order, images, fonts, js/css and finally everything else.
    SORT_ORDER = %w(.png .jpeg .jpg .gif .bmp .svg .svgz .ico .woff .otf .ttf .eot .js .css)

    attr_reader :app
    delegate :logger, :to => :app

    def initialize(app, opts={})
      @app = app
      @rack = ::Rack::Test::Session.new(app.class.to_rack_app)

      @glob = opts.has_key?("glob") ? opts["glob"] : nil

      @_file_output_callbacks = []
      @_file_error_callbacks = []
    end

    def on_file_output(&block)
      @_file_output_callbacks << block if block_given?
      @_file_output_callbacks
    end

    def on_file_error(&block)
      @_file_error_callbacks << block if block_given?
      @_file_error_callbacks
    end

    def run!
      prerender_css
      output_files
      ::Middleman::Profiling.report("build")
    end

  protected

    def request_path(path)
      @rack.get(URI.escape(path))
    end

    # Pre-request CSS to give Compass a chance to build sprites
    def prerender_css
      logger.debug "== Prerendering CSS"

      @app.sitemap.resources.select do |resource|
        resource.ext == ".css"
      end.each do |resource|
        request_path(resource.destination_path)
      end

      logger.debug "== Checking for Compass sprites"

      # Double-check for compass sprites
      @app.files.find_new_files((Pathname(@app.source_dir) + @app.images_dir).relative_path_from(@app.root_path))
      @app.sitemap.ensure_resource_list_updated!
    end

    def output_files
      logger.debug "== Building files"

      # Sort paths to be built by the above order. This is primarily so Compass can
      # find files in the build folder when it needs to generate sprites for the
      # css files.
      # 
      # Loop over all the paths and build them.
      @app.sitemap.resources.sort_by { |r|
        SORT_ORDER.index(r.ext) || 100
      }.select { |r|
        !@glob || File.fnmatch(@glob, r.destination_path)
      }.each do |r|
        output_resource(r)
      end
    end

    def output_resource(resource)
      output_file = File.join(@app.config[:build_dir], resource.destination_path)

      if resource.binary?
        file_did_output(output_file, resource.source_file, true)
      else
        begin
          response = request_path(resource.destination_path)

          if response.status == 200
            file_did_output(output_file, binary_encode(response.body), false)
          else
            handle_error(output_file, response.body, nil)
          end
        rescue => e
          handle_error(output_file, "#{e}\n#{e.backtrace.join("\n")}", e)
        end
      end
    end

    def binary_encode(string)
      if string.respond_to?(:force_encoding)
        string.force_encoding("ascii-8bit")
      end
      string
    end

    def handle_error(file_name, response, e)
      @_file_error_callbacks.each do |callback|
        callback.call(file_name, response, e)
      end
    end

    def file_did_output(output_file, source, binary=false)
      @_file_output_callbacks.each do |callback|
        callback.call(output_file, source, binary)
      end
    end
  end
end