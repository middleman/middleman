require 'digest/sha1'
module Middleman::Extensions
  module AssetHash
    class << self
      def registered(app, options)
        exts = options[:exts] || %w(.ico .manifest .jpg .jpeg .png .gif .js .css)

        app.after_configuration do
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
        @exts_regex_text = @exts.map {|e| Regexp.escape(e) }.join('|')
        @middleman_app = options[:middleman_app]
      end

      def call(env)
        status, headers, response = @rack_app.call(env)

        path = @middleman_app.full_path(env["PATH_INFO"])
        dirpath = Pathname.new(File.dirname(path))

        if path =~ /(^\/$)|(\.(htm|html|php|css|js)$)/
          body = case(response)
            when String
              response
            when Array
              response.join
            when Rack::Response
              response.body.join
            when Rack::File
              File.read(response.path)
            else
              response.to_s
          end

          if body
            # TODO: This regex will change some paths in plan HTML (not in a tag) - is that OK?
            body.gsub! /([=\'\"\(]\s*)([^\s\'\"\)]+(#{@exts_regex_text}))/ do |match|
              asset_path = $2
              relative_path = Pathname.new(asset_path).relative?

              asset_path = dirpath.join(asset_path).to_s if relative_path

              if @middleman_app.sitemap.exists? asset_path
                asset_page = @middleman_app.sitemap.page asset_path
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
