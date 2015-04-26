require 'rack'
require 'rack/response'
require 'addressable/uri'
require 'middleman-core/util'
require 'middleman-core/contracts'

module Middleman
  module Middleware
    class InlineURLRewriter
      include Contracts

      IGNORE_DESCRIPTOR = Or[Regexp, RespondTo[:call], String]

      Contract RespondTo[:call], ({
        middleman_app: IsA['Middleman::Application'],
        id: Maybe[Symbol],
        proc: Or[Proc, Method],
        url_extensions: ArrayOf[String],
        source_extensions: ArrayOf[String],
        ignore: ArrayOf[IGNORE_DESCRIPTOR]
      }) => Any
      def initialize(app, options={})
        @rack_app = app
        @middleman_app = options.fetch(:middleman_app)

        @uid = options.fetch(:id, nil)
        @proc = options.fetch(:proc)

        raise 'InlineURLRewriter requires a :proc to call with inline URL results' unless @proc

        @exts = options.fetch(:url_extensions)

        @source_exts = options.fetch(:source_extensions)
        @source_exts_regex_text = Regexp.union(@source_exts).to_s

        @ignore = options.fetch(:ignore)
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
              uri = ::Addressable::URI.parse(asset_path)

              relative_path = uri.host.nil?

              full_asset_path = if relative_path
                dirpath.join(asset_path).to_s
              else
                asset_path
              end

              @ignore.none? { |r| should_ignore?(r, full_asset_path) } && @proc.call(asset_path, dirpath, path)
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

      Contract IGNORE_DESCRIPTOR, String => Bool
      def should_ignore?(validator, value)
        if validator.is_a? Regexp
          # Treat as Regexp
          !value.match(validator).nil?
        elsif validator.respond_to? :call
          # Treat as proc
          validator.call(value)
        elsif validator.is_a? String
          # Treat as glob
          File.fnmatch(value, validator)
        else
          # If some unknown thing, don't ignore
          false
        end
      end
    end
  end
end
