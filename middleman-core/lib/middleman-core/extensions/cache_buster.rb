# The Cache Buster extension
class Middleman::Extensions::CacheBuster < ::Middleman::Extension
  option :exts, nil, 'List of extensions that get cache busters strings appended to them.'
  option :sources, %w[.css .htm .html .js .php .xhtml], 'List of extensions that are searched for bustable assets.'
  option :ignore, [], 'Regexes of filenames to skip adding query strings to'
  option :rewrite_ignore, [], 'Regexes of filenames to skip processing for path rewrites'

  def initialize(app, options_hash = {}, &block)
    super

    require 'set'
    @set_of_exts = Set.new(options.exts || app.config[:asset_extensions])
    @set_of_sources = Set.new options.sources

    app.rewrite_inline_urls id: :cache_buster,
                            url_extensions: @set_of_exts,
                            source_extensions: @set_of_sources,
                            ignore: options.ignore,
                            rewrite_ignore: options.rewrite_ignore,
                            proc: method(:rewrite_url)
  end

  Contract String, Or[String, Pathname], Any => String
  def rewrite_url(asset_path, _dirpath, _request_path)
    asset_path + '?' + Time.now.strftime('%s')
  end
end
