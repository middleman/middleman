# frozen_string_literal: true

# Relative Assets extension
class Middleman::Extensions::RelativeAssets < ::Middleman::Extension
  option :exts, nil, 'List of extensions that get converted to relative paths.'
  option :sources, %w[.css .htm .html .xhtml], 'List of extensions that are searched for relative assets.'
  option :ignore, [], 'Regexes of filenames to skip converting to relative paths.'
  option :rewrite_ignore, [], 'Regexes of filenames to skip processing for path rewrites.'
  option :helpers_only, false, 'Allow only Ruby helpers to change paths.'

  def initialize(app, options_hash = ::Middleman::EMPTY_HASH, &block)
    super

    require 'set'
    @set_of_exts = Set.new(options.exts || app.config[:asset_extensions])
    @set_of_sources = Set.new options.sources
  end

  Contract IsA['Middleman::Sitemap::ResourceListContainer'] => Any
  def manipulate_resource_list_container!(resource_list)
    return if options.helpers_only

    resource_list.by_extensions(@set_of_sources).each do |r|
      next if Array(options.rewrite_ignore || []).any? do |i|
        ::Middleman::Util.path_match(i, "/#{r.destination_path}")
      end

      r.add_filter ::Middleman::InlineURLRewriter.new(:relative_assets,
                                                      app,
                                                      r,
                                                      url_extensions: @set_of_exts,
                                                      ignore: options.ignore,
                                                      proc: method(:rewrite_url))
    end
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
    def asset_url(path, prefix = '', options_hash = ::Middleman::EMPTY_HASH)
      super(path, prefix, app.extensions[:relative_assets].mark_as_relative(super, options_hash, current_resource))
    end

    def asset_path(kind, source, options_hash = ::Middleman::EMPTY_HASH)
      super(kind, source, app.extensions[:relative_assets].mark_as_relative(super, options_hash, current_resource))
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
    
    Pathname(full_asset_path).relative_path_from(current_dir).to_s
  end
  memoize :rewrite_url
end
