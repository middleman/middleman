require 'digest/sha1'
module Middleman::Extensions
  module AssetHash
    class << self
      def registered(app)
        app.after_configuration do
          use Middleware, :ext => %w(ico manifest jpg png), :middleman_app => self
        end
      end
      alias :included :registered
    end

    class Middleware
      def initialize(app, options={})
        @rack_app      = app
        @ext           = options[:ext]
        @ext_pattern   = /\.(#{@ext.join('|')})$/
        @middleman_app = options[:middleman_app]
      end

      def call(env)
        status, headers, response = @rack_app.call(env)

        if env["PATH_INFO"] =~ /(^\/$)|(\.(htm|html|php|css|js)$)/
          puts '== AssetHash env["PATH_INFO"]: ' + env["PATH_INFO"]
          asset_paths = @middleman_app.sitemap.generic_paths.select {|p| p =~ @ext_pattern}

          if response.body.is_a?(Array)
            body = response.body.join
          else
            body = response.body
          end
          
          asset_paths.each do |asset_path| 
            puts "== AssetHash asset_path: " + asset_path
            hashed_asset_path = get_hashed_asset_path(asset_path)
            puts "== AssetHash hashed_asset_path: " + hashed_asset_path
          
            body = body.gsub(/(=|'|"|\()\s?(\/|(?:\.\.\/)+)?#{asset_path}\s?(\s|'|"|\))/, '\1\2' + hashed_asset_path + '\3')
          end
          status, headers, response = Rack::Response.new(body, status, headers).finish
        end
        [status, headers, response]
      end
            
      def get_hashed_asset_path(asset_path)
        @middleman_app.cache.fetch(:asset_hash, asset_path) do
          puts "== AssetHash Cache Miss: " + asset_path

          hashed_asset_path = digest_asset(asset_path)

          @middleman_app.reroute(hashed_asset_path, asset_path)
          @middleman_app.ignore(asset_path) # BUG => This file is still getting built even though it's sitemap status is ignored.

          # TODO => Add file_changed and file_deleted callbacks to add-to/clean-up the cache.
          hashed_asset_path
        end
      end
      
      def digest_asset(path, digest_length = 8)
        full_path = File.join(@middleman_app.source_dir, path)
        digest    = Digest::SHA1.file(full_path).hexdigest[0..(digest_length - 1)]
        path.sub(/\.(\w+)$/) { |ext| "-#{digest}#{ext}" }
      end

      # TODO => Remove this developer convenience method
      def mma
        @middleman_app
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