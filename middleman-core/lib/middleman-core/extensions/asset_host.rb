require 'addressable/uri'
require 'middleman-core/middleware/inline_url_rewriter'

class Middleman::Extensions::AssetHost < ::Middleman::Extension
  option :host, nil, 'The asset host to use or a Proc to determine asset host', required: true
  option :exts, %w(.css .png .jpg .jpeg .webp .svg .svgz .js .gif), 'List of extensions that get cache busters strings appended to them.'
  option :sources, %w(.htm .html .php .css .js), 'List of extensions that are searched for bustable assets.'
  option :ignore, [], 'Regexes of filenames to skip adding query strings to'

  def ready
    app.use ::Middleman::Middleware::InlineURLRewriter,
            id: :asset_host,
            url_extensions: options.exts,
            source_extensions: options.sources,
            ignore: options.ignore,
            middleman_app: app,
            proc: method(:rewrite_url)
  end

  Contract String, Or[String, Pathname], Any => String
  def rewrite_url(asset_path, dirpath, _request_path)
    uri = ::Addressable::URI.parse(asset_path)
    relative_path = uri.path[0..0] != '/'

    full_asset_path = if relative_path
      dirpath.join(asset_path).to_s
    else
      asset_path
    end

    asset_prefix = if options[:host].is_a?(Proc)
      options[:host].call(full_asset_path)
    elsif options[:host].is_a?(String)
      options[:host]
    end

    File.join(asset_prefix, full_asset_path)
  end
end
