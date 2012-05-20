require 'digest/sha1'
module Middleman::Extensions
  module AssetHash
    class << self
      def registered(app, options)
        exts = options[:exts] || %w(.jpg .jpeg .png .gif .js .css)

        ignore = Array(options[:ignore])

        app.ready do
          sitemap.register_resource_list_manipulator(
            :asset_hash, 
            AssetHashManager.new(self, exts, ignore)
          )
          use Middleware, :exts => exts, :middleman_app => self
        end
      end
      alias :included :registered
    end

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
          if @exts.include?(resource.ext) && @ignore.none? {|ignore| resource.path =~ ignore }
            # figure out the path Sprockets would use for this asset
            if resource.ext == '.js'
              sprockets_path = resource.path.sub(@app.js_dir,'').sub(/^\//,'')
            elsif resource.ext == '.css'
              sprockets_path = resource.path.sub(@app.css_dir,'').sub(/^\//,'')
            end

            # See if Sprockets knows about the file
            asset = @app.sprockets.find_asset(sprockets_path) if sprockets_path

            if asset # if it's a Sprockets asset, ask sprockets for its digest
              digest = asset.digest[0..7]
            elsif resource.template? # if it's a template, render it out
              digest = Digest::SHA1.hexdigest(resource.render)[0..7]
            else # if it's a static file, just hash it
              digest = Digest::SHA1.file(resource.source_file).hexdigest[0..7]
            end

            resource.destination_path = resource.destination_path.sub(/\.(\w+)$/) { |ext| "-#{digest}#{ext}" }
          end
        end
      end
    end

    # The asset hash middleware is responsible for rewriting references to
    # assets to include their new, hashed name.
    class Middleware
      def initialize(app, options={})
        @rack_app      = app
        @exts           = options[:exts]
        @exts_regex_text = @exts.map {|e| Regexp.escape(e) }.join('|')
        @middleman_app = options[:middleman_app]
      end

      def call(env)
        status, headers, response = @rack_app.call(env)

        path = @middleman_app.full_path(env["PATH_INFO"])
        dirpath = Pathname.new(File.dirname(path))

        if path =~ /(^\/$)|(\.(htm|html|php|css|js)$)/
          body = ::Middleman::Util.extract_response_text(response)

          if body
            # TODO: This regex will change some paths in plan HTML (not in a tag) - is that OK?
            body.gsub! /([=\'\"\(]\s*)([^\s\'\"\)]+(#{@exts_regex_text}))/ do |match|
              asset_path = $2
              relative_path = Pathname.new(asset_path).relative?

              asset_path = dirpath.join(asset_path).to_s if relative_path

              if asset_page = @middleman_app.sitemap.find_resource_by_path(asset_path)
                replacement_path = "/#{asset_page.destination_path}"
                replacement_path = Pathname.new(replacement_path).relative_path_from(dirpath).to_s if relative_path

                "#{$1}#{replacement_path}"
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
  
  register :asset_hash, AssetHash
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
