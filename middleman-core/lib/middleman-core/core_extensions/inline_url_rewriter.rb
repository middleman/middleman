require 'rack'
require 'rack/response'
require 'addressable/uri'
require 'middleman-core/util'
require 'middleman-core/contracts'

module Middleman
  module CoreExtensions

    class InlineURLRewriter < ::Middleman::Extension
      include Contracts

      expose_to_application rewrite_inline_urls: :add

      IGNORE_DESCRIPTOR = Or[Regexp, RespondTo[:call], String]
      REWRITER_DESCRIPTOR = {
        id: Symbol,
        proc: Or[Proc, Method],
        url_extensions: ArrayOf[String],
        source_extensions: ArrayOf[String],
        ignore: ArrayOf[IGNORE_DESCRIPTOR]
      }

      def initialize(app, options_hash={}, &block)
        super

        @rewriters = {}
      end

      Contract REWRITER_DESCRIPTOR => Any
      def add(options)
        @rewriters[options] = options
      end

      def after_configuration
        app.use Rack, {
          rewriters: @rewriters.values,
          middleman_app: @app
        }
      end

      class Rack
        include Contracts

        Contract RespondTo[:call], ({
          middleman_app: IsA['Middleman::Application'],
          rewriters: ArrayOf[REWRITER_DESCRIPTOR]
        }) => Any
        def initialize(app, options={})
          @rack_app = app
          @middleman_app = options.fetch(:middleman_app)
          @rewriters = options.fetch(:rewriters)
        end

        def call(env)
          status, headers, response = @rack_app.call(env)

          # Allow configuration or upstream request to skip all rewriting
          return [status, headers, response] if env['bypass_inline_url_rewriter'] == 'true'

          all_source_exts = @rewriters
              .reduce([]) { |sum, rewriter| sum + rewriter[:source_extensions] }
              .flatten
              .uniq
          source_exts_regex_text = Regexp.union(all_source_exts).to_s

          all_asset_exts = @rewriters
              .reduce([]) { |sum, rewriter| sum + rewriter[:url_extensions] }
              .flatten
              .uniq

          path = ::Middleman::Util.full_path(env['PATH_INFO'], @middleman_app)

          return [status, headers, response] unless path =~ /(^\/$)|(#{source_exts_regex_text}$)/
          return [status, headers, response] unless body = ::Middleman::Util.extract_response_text(response)

          dirpath = ::Pathname.new(File.dirname(path))

          rewritten = nil

          # ::Middleman::Util.instrument "inline_url_rewriter", path: path do
            rewritten = ::Middleman::Util.rewrite_paths(body, path, all_asset_exts) do |asset_path|
              uri = ::Addressable::URI.parse(asset_path)

              relative_path = uri.host.nil?

              full_asset_path = if relative_path
                dirpath.join(asset_path).to_s
              else
                asset_path
              end

              @rewriters.each do |rewriter|
                uid = rewriter.fetch(:id)

                # Allow upstream request to skip this specific rewriting
                next if env["bypass_inline_url_rewriter_#{uid}"] == 'true'

                exts = rewriter.fetch(:url_extensions)
                next unless exts.include?(::File.extname(asset_path))

                source_exts = rewriter.fetch(:source_extensions)
                next unless source_exts.include?(::File.extname(path))

                ignore = rewriter.fetch(:ignore)
                next if ignore.any? { |r| should_ignore?(r, full_asset_path) }

                rewrite_ignore = Array(rewriter.fetch(:rewrite_ignore, []))
                next if rewrite_ignore.any? { |ignore| ::Middleman::Util.path_match(ignore, path) }

                proc = rewriter.fetch(:proc)

                result = proc.call(asset_path, dirpath, path)
                asset_path = result if result
              end

              asset_path
            # end
          end

          ::Rack::Response.new(
            rewritten,
            status,
            headers
          ).finish
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
end
