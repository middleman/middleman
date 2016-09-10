require 'rack'
require 'rack/file'
require 'rack/lint'
require 'rack/head'
require 'rack/utils'

require 'middleman-core/util'
require 'middleman-core/logger'
require 'middleman-core/template_renderer'

# CSSPIE HTC File
::Rack::Mime::MIME_TYPES['.htc'] = 'text/x-component'

# Let's serve all HTML as UTF-8
::Rack::Mime::MIME_TYPES['.html'] = 'text/html; charset=utf-8'
::Rack::Mime::MIME_TYPES['.htm'] = 'text/html; charset=utf-8'

# Sourcemap format
::Rack::Mime::MIME_TYPES['.map'] = 'application/json; charset=utf-8'

# Create a MIME type for PHP files (for detection by extensions)
::Rack::Mime::MIME_TYPES['.php'] = 'text/php'

module Middleman
  class Rack
    extend Forwardable

    def to_app
      app = ::Rack::Builder.new

      app.use ::Rack::Lint
      app.use ::Rack::Head

      @middleman.middleware.each do |middleware|
        app.use(middleware[:class], *middleware[:options], &middleware[:block])
      end

      inner_app = self
      app.map('/') { run inner_app }

      @middleman.mappings.each do |mapping|
        app.map(mapping[:path], &mapping[:block])
      end

      app
    end

    def_delegator :"::Middleman::Logger", :singleton, :logger

    def initialize(middleman)
      @middleman = middleman
    end

    # Rack Interface
    #
    # @param env Rack environment
    def call(env)
      # Store environment, request and response for later
      req = ::Rack::Request.new(env)
      res = ::Rack::Response.new

      logger.debug "== Request: #{env['PATH_INFO']}"

      # Catch :halt exceptions and use that response if given
      catch(:halt) do
        process_request(env, req, res)
        res.status = 404
        res.finish
      end
    end

    # Halt the current request and return a response
    #
    # @param [String] response Response value
    def halt(response)
      throw :halt, response
    end

    # Core response method. We process the request, check with
    # the sitemap, and return the correct file, response or status
    # message.
    #
    # @param env
    # @param [Rack::Request] req
    # @param [Rack::Response] res
    def process_request(env, req, res)
      start_time = Time.now

      request_path = URI.decode(env['PATH_INFO'].dup)
      if request_path.respond_to? :force_encoding
        request_path.force_encoding('UTF-8')
      end
      request_path = ::Middleman::Util.full_path(request_path, @middleman)
      full_request_path = File.join(env['SCRIPT_NAME'], request_path) # Path including rack mount

      # Run before callbacks
      @middleman.execute_callbacks(:before)

      # Get the resource object for this path
      resource = @middleman.sitemap.find_resource_by_destination_path(request_path.gsub(' ', '%20'))

      # Return 404 if not in sitemap
      return not_found(res, full_request_path) unless resource && !resource.ignored?

      # If this path is a binary file, send it immediately
      return send_file(resource, env) if resource.binary?

      res['Content-Type'] = resource.content_type || 'text/plain'

      begin
        # Write out the contents of the page
        res.write resource.render({}, rack: { request: req })

        # Valid content is a 200 status
        res.status = 200
      rescue Middleman::TemplateRenderer::TemplateNotFound => e
        res.write "Error: #{e.message}"
        res.status = 500
      end

      # End the request
      logger.debug "== Finishing Request: #{resource.destination_path} (#{(Time.now - start_time).round(2)}s)"
      halt res.finish
    end

    # Halt request and return 404
    def not_found(res, path)
      path = ::Rack::Utils.escape_html(path)
      res.status = 404
      res.write "<html><head></head><body><h1>File Not Found</h1><p>#{path}</p></body></html>"
      res.finish
    end

    # Immediately send static file
    def send_file(resource, env)
      file     = ::Rack::File.new nil
      path     = resource.file_descriptor[:full_path]
      if !file.respond_to?(:path=)
        request  = ::Rack::Request.new(env)
        response = file.serving(request, path)
      else
        file.path = path
        response = file.serving(env)
      end
      status = response[0]
      response[1]['Content-Encoding'] = 'gzip' if %w(.svgz .gz).include?(resource.ext)
      # Do not set Content-Type if status is 1xx, 204, 205 or 304, otherwise
      # Rack will throw an error (500)
      if !(100..199).cover?(status) && ![204, 205, 304].include?(status)
        response[1]['Content-Type'] = resource.content_type || 'application/octet-stream'
      end
      halt response
    end
  end
end
