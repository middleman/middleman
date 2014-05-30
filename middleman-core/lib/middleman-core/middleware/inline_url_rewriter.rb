require 'middleman-core/util'
require 'rack'
require 'rack/response'

module Middleman
  module Middleware
    class InlineURLRewriter
      def initialize(app, options={})
        @rack_app = app
        @middleman_app = options[:middleman_app]

        @uid = options[:id]
        @proc = options[:proc]

        raise "InlineURLRewriter requires a :proc to call with inline URL results" unless @proc

        @exts = options[:url_extensions]

        @source_exts = options[:source_extensions]
        @source_exts_regex_text = Regexp.union(@source_exts).to_s

        @ignore = options[:ignore]
      end

      def call(env)
        status, headers, response = @rack_app.call(env)

        # Allow upstream request to skip all rewriting
        return [status, headers, response] if env['bypass_inline_url_rewriter'] == 'true'

        # Allow upstream request to skip this specific rewriting
        if @uid
          uid_key = "bypass_inline_url_rewriter_#{@uid}"
          return [status, headers, response] if env[uid_key] == 'true'
        end

        path = ::Middleman::Util.full_path(env['PATH_INFO'], @middleman_app)
    
        if path =~ /(^\/$)|(#{@source_exts_regex_text}$)/
          if body = ::Middleman::Util.extract_response_text(response)
            dirpath = Pathname.new(File.dirname(path))

            rewritten = ::Middleman::Util.rewrite_paths(body, path, @exts) do |asset_path|
              relative_path = Pathname.new(asset_path).relative?

              full_asset_path = if relative_path
                dirpath.join(asset_path).to_s
              else
                asset_path
              end

              @ignore.none? { |r| full_asset_path.match(r) } && @proc.call(asset_path, dirpath)
            end

            status, headers, response = ::Rack::Response.new(
              rewritten,
              status,
              headers
            ).finish
          end
        end

        [status, headers, response]
      end
    end
  end
end
