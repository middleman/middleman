require 'addressable/uri'

# Relative Assets extension
class Middleman::Extensions::RelativeAssets < ::Middleman::Extension
  option :exts, nil, 'List of extensions that get converted to relative paths.'
  option :sources, %w(.css .htm .html .xhtml), 'List of extensions that are searched for relative assets.'
  option :ignore, [], 'Regexes of filenames to skip converting to relative paths.'
  option :rewrite_ignore, [], 'Regexes of filenames to skip processing for path rewrites.'
  option :helpers_only, false, 'Allow only Ruby helpers to change paths.'

  def initialize(app, options_hash={}, &block)
    super

    return if options[:helpers_only]

    app.rewrite_inline_urls id: :relative_assets,
                            url_extensions: options.exts || app.config[:asset_extensions],
                            source_extensions: options.sources,
                            ignore: options.ignore,
                            rewrite_ignore: options.rewrite_ignore,
                            proc: method(:rewrite_url)
  end

  def mark_as_relative(file_path, opts, current_resource)
    result = opts.dup

    valid_exts = options.sources

    return result unless current_resource
    return result unless valid_exts.include?(current_resource.ext)

    rewrite_ignores = Array(options.rewrite_ignore || [])

    path = current_resource.destination_path
    return result if rewrite_ignores.any? do |i|
      ::Middleman::Util.path_match(i, path) || ::Middleman::Util.path_match(i, "/#{path}")
    end

    return result if Array(options.ignore || []).any? do |r|
      ::Middleman::Util.should_ignore?(r, file_path)
    end

    result[:relative] = true unless result.key?(:relative)

    result
  end

  helpers do
    def asset_url(path, prefix='', options={})
      super(path, prefix, app.extensions[:relative_assets].mark_as_relative(super, options, current_resource))
    end

    def asset_path(kind, source, options={})
      super(kind, source, app.extensions[:relative_assets].mark_as_relative(super, options, current_resource))
    end
  end

  Contract String, Or[String, Pathname], Any => Maybe[String]
  def rewrite_url(asset_path, dirpath, request_path)
    uri = ::Middleman::Util.parse_uri(asset_path)

    return if uri.path[0..0] != '/'

    relative_path = uri.host.nil?

    full_asset_path = if relative_path
      dirpath.join(asset_path).to_s
    else
      asset_path
    end

    current_dir = Pathname(request_path).dirname
    result = Pathname(full_asset_path).relative_path_from(current_dir).to_s

    result
  end
  memoize :rewrite_url
end
