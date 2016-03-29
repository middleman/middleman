class Middleman::Extensions::AssetHost < ::Middleman::Extension
  option :host, nil, 'The asset host to use or a Proc to determine asset host', required: true
  option :exts, nil, 'List of extensions that get cache busters strings appended to them.'
  option :sources, %w[.css .htm .html .js .php .xhtml], 'List of extensions that are searched for bustable assets.'
  option :ignore, [], 'Regexes of filenames to skip adding query strings to'
  option :rewrite_ignore, [], 'Regexes of filenames to skip processing for host rewrites'

  def initialize(app, options_hash = {}, &block)
    super

    require 'set'
    @set_of_exts = Set.new(options.exts || app.config[:asset_extensions])
    @set_of_sources = Set.new options.sources
  end

  Contract IsA['Middleman::Sitemap::ResourceListContainer'] => Any
  def manipulate_resource_list_container!(resource_list)
    resource_list.by_exts(@set_of_sources).each do |r|
      next if Array(options.rewrite_ignore || []).any? do |i|
        ::Middleman::Util.path_match(i, "/#{r.destination_path}")
      end

      r.filters << ::Middleman::InlineURLRewriter.new(:asset_host,
                                                      app,
                                                      r,
                                                      after_filter: :asset_hash,
                                                      url_extensions: @set_of_exts,
                                                      ignore: options.ignore,
                                                      proc: method(:rewrite_url))
    end
  end

  Contract String, Or[String, Pathname], Any => String
  def rewrite_url(asset_path, dirpath, _request_path)
    uri = ::Middleman::Util.parse_uri(asset_path)
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
  memoize :rewrite_url
end
