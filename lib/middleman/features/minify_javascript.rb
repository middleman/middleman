module Middleman::Features::MinifyJavascript
  class << self
    def registered(app)
      require 'uglifier'
      app.set :js_compressor, ::Uglifier.new
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

        if response.is_a?(::Rack::File) or response.is_a?(::Sinatra::Helpers::StaticFile)
          uncompressed_source = File.read(response.path)
        else
          uncompressed_source = response.join
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