# The Cache Buster extension
class Middleman::Extensions::CacheBuster < ::Middleman::Extension
  option :exts, nil, 'List of extensions that get cache busters strings appended to them.'
  option :sources, %w[.css .htm .html .js .mjs .php .xhtml], 'List of extensions that are searched for bustable assets.'
  option :ignore, [], 'Regexes of filenames to skip adding query strings to'
  option :rewrite_ignore, [], 'Regexes of filenames to skip processing for path rewrites'

  def initialize(app, options_hash = ::Middleman::EMPTY_HASH, &block)
    super

    require 'set'
    @set_of_exts = Set.new(options.exts || app.config[:asset_extensions])
    @set_of_sources = Set.new options.sources
  end

  Contract IsA['Middleman::Sitemap::ResourceListContainer'] => Any
  def manipulate_resource_list_container!(resource_list)
    resource_list.by_extensions(@set_of_sources).each do |r|
      next if Array(options.rewrite_ignore || []).any? do |i|
        ::Middleman::Util.path_match(i, "/#{r.destination_path}")
      end

      r.add_filter ::Middleman::InlineURLRewriter.new(:cache_buster,
                                                      app,
                                                      r,
                                                      url_extensions: @set_of_exts,
                                                      ignore: options.ignore,
                                                      proc: method(:rewrite_url))
    end
  end

  Contract String, Or[String, Pathname], Any => String
  def rewrite_url(asset_path, _dirpath, _request_path)
    asset_path + '?' + Time.now.strftime('%s')
  end
end
