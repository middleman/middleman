# Relative Assets extension
class Middleman::Extensions::RelativeAssets < ::Middleman::Extension
  option :exts, %w(.css .png .jpg .jpeg .svg .svgz .js .gif .ttf .otf .woff), 'List of extensions that get cache busters strings appended to them.'
  option :sources, %w(.htm .html .css), 'List of extensions that are searched for relative assets.'
  option :ignore, [], 'Regexes of filenames to skip adding query strings to'

  def initialize(app, options_hash={}, &block)
    super

    require 'middleman-core/middleware/inline_url_rewriter'
  end

  def after_configuration
    app.use ::Middleman::Middleware::InlineURLRewriter,
            id: :asset_hash,
            url_extensions: options.exts,
            source_extensions: options.sources,
            ignore: options.ignore,
            middleman_app: app,
            proc: method(:rewrite_url)
  end

  def rewrite_url(asset_path, dirpath, request_path)
    relative_path = Pathname.new(asset_path).relative?

    full_asset_path = if relative_path
      dirpath.join(asset_path).to_s
    else
      asset_path
    end

    return unless !full_asset_path.include?('//') && !asset_path.start_with?('data:')

    current_dir = Pathname('/' + request_path).dirname
    Pathname(full_asset_path).relative_path_from(current_dir).to_s
  end
end
