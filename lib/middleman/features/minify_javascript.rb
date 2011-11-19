module Middleman::Features::MinifyJavascript
  class << self
    def registered(app)
      require 'uglifier'
      app.after_configuration do
        app.set :js_compressor, ::Uglifier.new
      end
      app.use InlineJavascriptRack
    end
    alias :included :registered
  end

  class InlineJavascriptRack
    def initialize(app, options={})
      @app = app
    end

    def call(env)
      status, headers, response = @app.call(env)

      if env["PATH_INFO"].match(/\.html$/)
        compressor = ::Uglifier.new

        uncompressed_source = case(response)
          when String
            response
          when Array
            response.join
          when Rack::Response
            response.body.join
          when Rack::File
            File.read(response.path)
        end

        minified = uncompressed_source.gsub(/(<scri.*?\/\/<!\[CDATA\[\n)(.*?)(\/\/\]\].*?<\/script>)/m) do |m|
          first = $1
          uncompressed_source = $2
          last = $3
          minified_js = compressor.compile(uncompressed_source)

          first << minified_js << "\n" << last
        end
        headers["Content-Length"] = ::Rack::Utils.bytesize(minified).to_s
        response = [minified]
      end

      [status, headers, response]
    end
  end
end