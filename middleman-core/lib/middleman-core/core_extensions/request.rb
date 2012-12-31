# Built on Rack
require "rack"
require "rack/file"

module Middleman
  module CoreExtensions

    # Base helper to manipulate asset paths
    module Request

      # Extension registered
      class << self
        # @private
        def registered(app)

          # CSSPIE HTC File
          ::Rack::Mime::MIME_TYPES['.htc'] = 'text/x-component'

          # Let's serve all HTML as UTF-8
          ::Rack::Mime::MIME_TYPES['.html'] = 'text/html; charset=utf-8'
          ::Rack::Mime::MIME_TYPES['.htm'] = 'text/html; charset=utf-8'

          app.extend ClassMethods
          app.extend ServerMethods

          Middleman.extend CompatibleClassMethods

          # Include instance methods
          app.send :include, InstanceMethods
        end
        alias :included :registered
      end

      module ClassMethods
        # Reset Rack setup
        #
        # @private
        def reset!
          @app = nil
        end

        # The shared Rack instance being build
        #
        # @private
        # @return [Rack::Builder]
        def app
          @app ||= ::Rack::Builder.new
        end

        # Get the static instance
        #
        # @private
        # @return [Middleman::Application]
        def inst(&block)
          @inst ||= begin
            mm = new(&block)
            mm.run_hook :ready
            mm
          end
        end

        # Set the shared instance
        #
        # @private
        # @param [Middleman::Application] inst
        # @return [void]
        def inst=(inst)
          @inst = inst
        end

        # Return built Rack app
        #
        # @private
        # @return [Rack::Builder]
        def to_rack_app(&block)
          inner_app = inst(&block)

          (@middleware || []).each do |m|
            app.use(m[0], *m[1], &m[2])
          end

          app.map("/") { run inner_app }

          (@mappings || []).each do |m|
            app.map(m[0], &m[1])
          end

          app
        end

        # Prototype app. Used in config.ru
        #
        # @private
        # @return [Rack::Builder]
        def prototype
          reset!
          to_rack_app
        end

        # Call prototype, use in config.ru
        #
        # @private
        def call(env)
          prototype.call(env)
        end

        # Use Rack middleware
        #
        # @param [Class] middleware Middleware module
        # @return [void]
        def use(middleware, *args, &block)
          @middleware ||= []
          @middleware << [middleware, args, block]
        end

        # Add Rack App mapped to specific path
        #
        # @param [String] map Path to map
        # @return [void]
        def map(map, &block)
          @mappings ||= []
          @mappings << [map, block]
        end
      end

      module ServerMethods
        # Create a new Class which is based on Middleman::Application
        # Used to create a safe sandbox into which extensions and
        # configuration can be included later without impacting
        # other classes and instances.
        #
        # @return [Class]
        def server(&block)
          @@servercounter ||= 0
          @@servercounter += 1
          const_set("MiddlemanApplication#{@@servercounter}", Class.new(Middleman::Application))
        end
      end

      module CompatibleClassMethods
        # Create a new Class which is based on Middleman::Application
        # Used to create a safe sandbox into which extensions and
        # configuration can be included later without impacting
        # other classes and instances.
        #
        # @return [Class]
        def server(&block)
          ::Middleman::Application.server
        end
      end

      # Methods to be mixed-in to Middleman::Application
      module InstanceMethods
        # Backwards-compatibility with old request.path signature
        attr_reader :request

        # Accessor for current path
        # @return [String]
        attr_reader :current_path

        # Set the current path
        #
        # @param [String] path The new current path
        # @return [void]
        def current_path=(path)
          @current_path = path
          @request = ::Thor::CoreExt::HashWithIndifferentAccess.new({
            :path   => path,
            :params => req ? ::Thor::CoreExt::HashWithIndifferentAccess.new(req.params) : {}
          })
        end

        def use(*args, &block); self.class.use(*args, &block); end
        def map(*args, &block); self.class.map(*args, &block); end

        # Rack env
        attr_accessor :env

        # Rack request
        # @return [Rack::Request]
        attr_accessor :req

        # Rack response
        # @return [Rack::Response]
        attr_accessor :res

        def call(env)
          dup.call!(env)
        end

        # Rack Interface
        #
        # @param env Rack environment
        def call!(env)
          self.env = env
          # Store environment, request and response for later
          self.req = req = ::Rack::Request.new(env)
          self.res = res = ::Rack::Response.new

          logger.debug "== Request: #{env["PATH_INFO"]}"

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
          @current_path = nil

          request_path = URI.decode(env["PATH_INFO"].dup)
          if request_path.respond_to? :force_encoding
            request_path.force_encoding('UTF-8')
          end
          request_path = full_path(request_path)

          # Run before callbacks
          run_hook :before

          # Get the resource object for this path
          resource = sitemap.find_resource_by_destination_path(request_path)

          # Return 404 if not in sitemap
          return not_found(res, request_path) unless resource && !resource.ignored?

          # If this path is a binary file, send it immediately
          return send_file(resource.source_file, env, res) if resource.binary?

          current_path = resource.destination_path

          # Set a HTTP content type based on the request's extensions
          content_type(res, resource.mime_type)

          begin
            # Write out the contents of the page
            output = resource.render do
              self.req = req
              self.current_path = current_path
            end

            res.write output
            # Valid content is a 200 status
            res.status = 200
          rescue Middleman::CoreExtensions::Rendering::TemplateNotFound => e
            res.write "Error: #{e.message}"
            res.status = 500
          end

          # End the request
          logger.debug "== Finishing Request: #{current_path} (#{(Time.now - start_time).round(2)}s)"
          halt res.finish
        end

        # Add a new mime-type for a specific extension
        #
        # @param [Symbol] type File extension
        # @param [String] value Mime type
        # @return [void]
        def mime_type(type, value=nil)
          return type if type.nil? || type.to_s.include?('/')
          type = ".#{type}" unless type.to_s[0] == ?.
          return ::Rack::Mime.mime_type(type, nil) unless value
          ::Rack::Mime::MIME_TYPES[type] = value
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
          matched_mime = mime_type(extension)
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
          mime_type = mime_type(type) || default
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
end
