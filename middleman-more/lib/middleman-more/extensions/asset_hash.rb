require 'digest/sha1'
module Middleman::Extensions
  module AssetHash
    class << self
      def registered(app, options)
        exts = options[:exts] || %w(.ico .manifest .jpg .jpeg .png .gif .js .css)

        app.after_configuration do
          # Register a reroute transform that adds .gz to asset paths
          sitemap.reroute do |destination, page|
            if exts.include? page.ext
              app.cache.fetch(:asset_hash, page.path) do
                digest    = Digest::SHA1.file(page.source_file).hexdigest[0..7]
                destination.sub(/\.(\w+)$/) { |ext| "-#{digest}#{ext}" }
              end
            else
              destination
            end
          end

          use Middleware, :exts => exts, :middleman_app => self
        end
      end
      alias :included :registered
    end

    class Middleware
      def initialize(app, options={})
        @rack_app      = app
        @exts           = options[:exts]
        @middleman_app = options[:middleman_app]
      end

      def call(env)
        status, headers, response = @rack_app.call(env)

        path = env["PATH_INFO"]

        if path =~ /(^\/$)|(\.(htm|html|php|css|js)$)/
          asset_pages = @middleman_app.sitemap.pages.select {|p| @exts.include? p.ext }

          body = case(response)
            when String
              response
            when Array
              response.join
            when Rack::Response
              response.body.join
            when Rack::File
              File.read(response.path)
          end
          
          if body
            asset_pages.each do |asset_page| 
              # TODO: This will have to be smarter to handle relative_assets
              # TODO: This regex will change some paths in plan HTML (not in a tag) - is that OK?
              # TODO: The part of the regex that handles relative paths sucks
              body = body.gsub(/(=|'|"|\()\s?(\/|(?:\.\.\/)+)?#{Regexp.escape(asset_page.path)}\s?(\s|'|"|\))/, '\1\2'+ asset_page.destination_path + '\3')
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
