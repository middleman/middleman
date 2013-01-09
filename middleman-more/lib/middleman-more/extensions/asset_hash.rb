module Middleman
  module Extensions
    module AssetHash
      class << self
        def registered(app, options={})
          require 'digest/sha1'
          require 'rack/test'
          require 'uri'

          exts = options[:exts] || %w(.jpg .jpeg .png .gif .js .css .otf .woff .eot .ttf .svg)

          # Allow specifying regexes to ignore, plus always ignore apple touch icons
          ignore = Array(options[:ignore]) << /^apple-touch-icon/

          app.ready do
            sitemap.register_resource_list_manipulator(
              :asset_hash,
              AssetHashManager.new(self, exts, ignore)
            )

            use Middleware, :exts => exts, :middleman_app => self, :ignore => ignore
          end
        end
        alias :included :registered
      end

      # Central class for managing asset_hash extension
      class AssetHashManager
        def initialize(app, exts, ignore)
          @app = app
          @exts = exts
          @ignore = ignore
        end

        # Update the main sitemap resource list
        # @return [void]
        def manipulate_resource_list(resources)
          resources.each do |resource|
            next unless @exts.include? resource.ext
            next if @ignore.any? { |ignore| Middleman::Util.path_match(ignore, resource.destination_path) }

            # Render through the Rack interface so middleware and mounted apps get a shot
            rack_client = ::Rack::Test::Session.new(@app.class)
            response = rack_client.get(URI.escape(resource.destination_path), {}, { "bypass_asset_hash" => true })
            raise "#{resource.path} should be in the sitemap!" unless response.status == 200

            digest = Digest::SHA1.hexdigest(response.body)[0..7]

            resource.destination_path = resource.destination_path.sub(/\.(\w+)$/) { |ext| "-#{digest}#{ext}" }
          end
        end
      end

      # The asset hash middleware is responsible for rewriting references to
      # assets to include their new, hashed name.
      class Middleware
        def initialize(app, options={})
          @rack_app        = app
          @exts            = options[:exts]
          @ignore          = options[:ignore]
          @exts_regex_text = @exts.map {|e| Regexp.escape(e) }.join('|')
          @middleman_app   = options[:middleman_app]
        end

        def call(env)
          status, headers, response = @rack_app.call(env)

          # We don't want to use this middleware when rendering files to figure out their hash!
          return [status, headers, response] if env["bypass_asset_hash"]

          path = @middleman_app.full_path(env["PATH_INFO"])
          dirpath = Pathname.new(File.dirname(path))

          if path =~ /(^\/$)|(\.(htm|html|php|css|js)$)/
            body = ::Middleman::Util.extract_response_text(response)

            if body
              # TODO: This regex will change some paths in plan HTML (not in a tag) - is that OK?
              body.gsub! /([=\'\"\(]\s*)([^\s\'\"\)]+(#{@exts_regex_text}))/ do |match|
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

              status, headers, response = Rack::Response.new(body, status, headers).finish
            end
          end
          [status, headers, response]
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
