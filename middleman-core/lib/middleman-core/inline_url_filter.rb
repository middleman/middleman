require 'middleman-core/util'
require 'middleman-core/filter'
require 'middleman-core/contracts'

module Middleman
  class InlineURLRewriter < Filter
    include Contracts

    Contract Symbol, IsA['::Middleman::Application'], IsA['::Middleman::Sitemap::Resource'], Hash => Any
    def initialize(filter_name, app, resource, options_hash = ::Middleman::EMPTY_HASH)
      super(filter_name, options_hash)

      @app = app
      @resource = resource
    end

    Contract String, Pathname => Maybe[IsA['::Middleman::Sitemap::Resource']]
    def target_resource(asset_path, dirpath)
      uri = ::Middleman::Util.parse_uri(asset_path)
      relative_path = !uri.path.start_with?('/')

      full_asset_path = if relative_path
                          dirpath.join(asset_path).to_s
                        else
                          asset_path
                        end

      @app.sitemap.by_destination_path(full_asset_path) || @app.sitemap.by_path(full_asset_path)
    end

    Contract String => [String, Maybe[SetOf[String]]]
    def execute_filter(body)
      path = "/#{@resource.destination_path}"
      dirpath = ::Pathname.new(File.dirname(path))

      ::Middleman::Util.instrument 'inline_url_filter', path: path do
        deps = Set.new

        new_content = ::Middleman::Util.rewrite_paths(body, path, @options.fetch(:url_extensions), @app) do |asset_path|
          uri = ::Middleman::Util.parse_uri(asset_path)

          relative_path = uri.host.nil?
          full_asset_path = if relative_path
                              dirpath.join(asset_path).to_s
                            else
                              asset_path
                            end

          exts = @options.fetch(:url_extensions)
          next unless exts.include?(::File.extname(asset_path))

          next if @options.fetch(:ignore).any? { |r| ::Middleman::Util.should_ignore?(r, full_asset_path) }

          result = @options.fetch(:proc).call(asset_path, dirpath, path)

          if result
            deps << target_resource(asset_path, dirpath).source_file if @options.fetch(:create_dependencies, false)

            asset_path = result
          end

          asset_path
        end

        [new_content, deps]
      end
    end
  end
end
