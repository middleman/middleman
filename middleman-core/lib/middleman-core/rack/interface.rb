# Built on Rack
require "rack"
require "rack/file"

module Middleman
  module Rack

    module Interface
      def self.included(app)
        app.send :include, InstanceMethods
      end

      module InstanceMethods
        def call(env)
          @_rack_interface ||= ::Middleman::Rack::API.new(self)
          @_rack_interface.call(env)
        end
      end
    end

    class API
      attr_accessor :middleman_app

      def initialize(app)
        self.middleman_app = app# unless app.nil?
      end

      def call(env)
        req = ::Rack::Request.new(env)
        res = ::Rack::Response.new

        # Catch :halt exceptions and use that response if given
        catch(:halt) do
          process_request(env, req, res)
          res.status = 404
          res.finish
        end
      end

    protected

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
        request_path = URI.decode(env["PATH_INFO"].dup)
        if request_path.respond_to? :force_encoding
          request_path.force_encoding('UTF-8')
        end

        begin
          output, mime, static_file = middleman_app.dup.render(request_path)

          if static_file
            # If this path is a static file, send it immediately
            return send_file(static_file, env, res)
          end

          # Set a HTTP content type based on the request's extensions
          content_type(res, mime)

          res.write output
          res.status = 200
        rescue ::Middleman::Application::FileNotFound => e
          return not_found(res, request_path)
        rescue => e
          res.write "Error: #{e.message}"
          res.status = 500
        end

        halt res.finish
      end

      # Halt request and return 404
      def not_found(res, path)
        res.status == 404
        res.write "<html><body><h1>File Not Found</h1><p>#{path}</p></body>"
        res.finish
      end

      # Immediately send static file
      #
      # @param [String] path File to send
      def send_file(path, env, res)
        extension = File.extname(path)
        matched_mime = ::Middleman::Util.mime_type(extension)
        matched_mime = "application/octet-stream" if matched_mime.nil?
        content_type res, matched_mime

        file      = ::Rack::File.new nil
        file.path = path
        response = file.serving(env)
        response[1]['Content-Encoding'] = 'gzip' if %w(.svgz).include?(extension)
        halt response
      end

      # Set the content type for the current request
      #
      # @param [String] type Content type
      # @param [Hash] params
      # @return [void]
      def content_type(res, type, params={})
        return res['Content-Type'] unless type
        default = params.delete :default
        mime_type = ::Middleman::Util.mime_type(type) || default
        throw "Unknown media type: %p" % type if mime_type.nil?
        mime_type = mime_type.dup
        unless params.include? :charset
          params[:charset] = params.delete('charset') || "utf-8"
        end
        params.delete :charset if mime_type.include? 'charset'
        unless params.empty?
          mime_type << (mime_type.include?(';') ? ', ' : ';')
          mime_type << params.map { |kv| kv.join('=') }.join(', ')
        end
        res['Content-Type'] = mime_type
      end
    end
  end
end
