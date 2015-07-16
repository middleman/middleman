require 'middleman-core/util'

class Middleman::Extensions::AssetHash < ::Middleman::Extension
  option :exts, %w(.jpg .jpeg .png .gif .webp .js .css .otf .woff .woff2 .eot .ttf .svg .svgz), 'List of extensions that get asset hashes appended to them.'
  option :ignore, [], 'Patterns to avoid adding asset hashes to'

  def initialize(app, options_hash={}, &block)
    super

    require 'digest/sha1'
    require 'rack/test'
    require 'uri'
  end

  def after_configuration
    # Allow specifying regexes to ignore, plus always ignore apple touch icons
    @ignore = Array(options.ignore) + [/^apple-touch-icon/]

    app.use Middleware, exts: options.exts, middleman_app: app, ignore: @ignore
  end

  # Update the main sitemap resource list
  # @return [void]
  def manipulate_resource_list(resources)
    @rack_client ||= ::Rack::Test::Session.new(app.class.to_rack_app)

    # Process resources in order: binary images and fonts, then SVG, then JS/CSS.
    # This is so by the time we get around to the text files (which may reference
    # images and fonts) the static assets' hashes are already calculated.
    resources.sort_by do |a|
      if %w(.svg).include? a.ext
        0
      elsif %w(.js .css).include? a.ext
        1
      else
        -1
      end
    end.each(&method(:manipulate_single_resource))
  end

  def manipulate_single_resource(resource)
    return unless options.exts.include?(resource.ext)
    return if ignored_resource?(resource)
    return if resource.ignored?

    # Render through the Rack interface so middleware and mounted apps get a shot
    response = @rack_client.get(URI.escape(resource.destination_path), {},  'bypass_asset_hash' => 'true')
    raise "#{resource.path} should be in the sitemap!" unless response.status == 200

    digest = Digest::SHA1.hexdigest(response.body)[0..7]

    resource.destination_path = resource.destination_path.sub(/\.(\w+)$/) { |ext| "-#{digest}#{ext}" }
  end

  def ignored_resource?(resource)
    @ignore.any? { |ignore| Middleman::Util.path_match(ignore, resource.destination_path) }
  end

  # The asset hash middleware is responsible for rewriting references to
  # assets to include their new, hashed name.
  class Middleware
    def initialize(app, options={})
      @rack_app        = app
      @exts            = options[:exts]
      @ignore          = options[:ignore]
      @exts_regex_text = @exts.map { |e| Regexp.escape(e) }.sort.reverse.join('|')
      @middleman_app   = options[:middleman_app]
    end

    def call(env)
      status, headers, response = @rack_app.call(env)

      # We don't want to use this middleware when rendering files to figure out their hash!
      return [status, headers, response] if env['bypass_asset_hash'] == 'true'

      path = ::Middleman::Util.full_path(env['PATH_INFO'], @middleman_app)

      if path =~ /(^\/$)|(\.(htm|html|php|css|js|json)$)/
        body = ::Middleman::Util.extract_response_text(response)
        if body
          status, headers, response = Rack::Response.new(rewrite_paths(body, path), status, headers).finish
        end
      end

      [status, headers, response]
    end

    private

    def rewrite_paths(body, path)
      dirpath = Pathname.new(File.dirname(path))

      # TODO: This regex will change some paths in plan HTML (not in a tag) - is that OK?
      body.gsub(/([=\'\"\(,]\s*)([^\s\'\"\)]+(#{@exts_regex_text}))/) do |match|
        opening_character = $1
        asset_path = $2

        relative_path = Pathname.new(asset_path).relative?

        asset_path = dirpath.join(asset_path).to_s if relative_path

        if @ignore.any? { |r| asset_path.match(r) }
          match
        elsif asset_page = @middleman_app.sitemap.find_resource_by_path(asset_path)
          replacement_path = "/#{asset_page.destination_path}"
          replacement_path = Pathname.new(replacement_path).relative_path_from(dirpath).to_s if relative_path

          "#{opening_character}#{replacement_path}"
        else
          match
        end
      end
    end
  end
end

# =================Temp Generate Test data==============================
#   ["jpg", "png", "gif"].each do |ext|
#     [["<p>", "</p>"], ["<p><img src=", " /></p>"], ["<p>background-image:url(", ");</p>"]].each do |outer|
#       [["",""], ["'", "'"], ['"','"']].each do |inner|
#         [["", ""], ["/", ""], ["../", ""], ["../../", ""], ["../../../", ""], ["http://example.com/", ""], ["a","a"], ["1","1"], [".", "."], ["-","-"], ["_","_"]].each do |path_parts|
#           name = 'images/100px.'
#           puts outer[0] + inner[0] + path_parts[0] + name + ext + path_parts[1] + inner[1] + outer[1]
#         end
#       end
#     end
#     puts "<br /><br /><br />"
#   end
