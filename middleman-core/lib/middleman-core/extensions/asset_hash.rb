require 'middleman-core/util'

class Middleman::Extensions::AssetHash < ::Middleman::Extension
  option :sources, %w[.css .htm .html .js .mjs .json .php .xhtml], 'List of extensions that are searched for hashable assets.'
  option :exts, nil, 'List of extensions that get asset hashes appended to them.'
  option :ignore, [], 'Regexes of filenames to skip adding asset hashes to'
  option :rewrite_ignore, [], 'Regexes of filenames to skip processing for path rewrites'
  option :prefix, '', 'Prefix for hash'

  def initialize(app, options_hash = ::Middleman::EMPTY_HASH, &block)
    super

    # Allow specifying regexes to ignore, plus always ignore apple touch icons
    @ignore = Array(options.ignore) + [/^apple-touch-icon/]

    require 'set'

    # Exclude .ico from the default list because browsers expect it
    # to be named "favicon.ico"
    @set_of_exts = Set.new(options.exts || (app.config[:asset_extensions] - %w[.ico]))
    @set_of_sources = Set.new options.sources
  end

  Contract String, Or[String, Pathname], Any => Maybe[String]
  def rewrite_url(asset_path, dirpath, _request_path)
    uri = ::Middleman::Util.parse_uri(asset_path)
    relative_path = !uri.path.start_with?('/')

    full_asset_path = if relative_path
                        dirpath.join(asset_path).to_s
                      else
                        asset_path
                      end

    asset_page = app.sitemap.by_destination_path(full_asset_path) || app.sitemap.by_path(full_asset_path)

    return unless asset_page

    replacement_path = "/#{asset_page.destination_path}"
    replacement_path = Pathname.new(replacement_path).relative_path_from(dirpath).to_s if relative_path
    replacement_path
  end

  # Update the main sitemap resource list
  Contract IsA['Middleman::Sitemap::ResourceListContainer'] => Any
  def manipulate_resource_list_container!(resource_list)
    resource_list.by_extensions(@set_of_sources).each do |r|
      next if Array(options.rewrite_ignore || []).any? do |i|
        ::Middleman::Util.path_match(i, "/#{r.destination_path}")
      end

      r.add_filter ::Middleman::InlineURLRewriter.new(:asset_hash,
                                                      app,
                                                      r,
                                                      create_dependencies: true,
                                                      url_extensions: @set_of_exts,
                                                      ignore: options.ignore,
                                                      proc: method(:rewrite_url))
    end

    # Process resources in order: binary images and fonts, then SVG, then JS/CSS.
    # This is so by the time we get around to the text files (which may reference
    # images and fonts) the static assets' hashes are already calculated.
    sorted_resources = resource_list.by_extensions(@set_of_exts).sort_by do |a|
      if %w[.svg .svgz].include? a.ext
        0
      elsif %w[.js .mjs .css].include? a.ext
        1
      else
        -1
      end
    end

    sorted_resources.each do |resource|
      manipulate_single_resource(resource_list, resource)
    end
  end

  Contract IsA['Middleman::Sitemap::ResourceListContainer'], IsA['Middleman::Sitemap::Resource'] => Any
  def manipulate_single_resource(resource_list, resource)
    return if ignored_resource?(resource)
    return if resource.ignored?

    digest = if resource.binary? || resource.static_file?
               ::Middleman::Util.hash_file(resource.source_file)[0..7]
             else
               # Render without asset hash
               body = resource.render({}, {}) { |f| !f.respond_to?(:filter_name) || f.filter_name != :asset_hash }
               ::Middleman::Util.hash_string(body)[0..7]
             end

    resource_list.update!(resource, :destination_path) do
      resource.destination_path = resource.destination_path.sub(/\.(\w+)$/) { |ext| "-#{options.prefix}#{digest}#{ext}" }
    end
  end

  Contract IsA['Middleman::Sitemap::Resource'] => Bool
  def ignored_resource?(resource)
    @ignore.any? do |ignore|
      Middleman::Util.path_match(ignore, resource.destination_path)
    end
  end
end
