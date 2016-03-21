require 'middleman-core/contracts'

module Middleman
  module Util
    include Contracts

    module_function

    # Extract the text of a Rack response as a string.
    # Useful for extensions implemented as Rack middleware.
    # @param response The response from #call
    # @return [String] The whole response as a string.
    Contract RespondTo[:each] => String
    def extract_response_text(response)
      # The rack spec states all response bodies must respond to each
      result = ''
      response.each do |part, _|
        result << part
      end
      result
    end

    Contract String, String, ArrayOf[String], Proc => String
    def rewrite_paths(body, _path, exts, &_block)
      matcher = /([\'\"\(,]\s*|# sourceMappingURL=)([^\s\'\"\)>]+(#{::Regexp.union(exts)}))/

      url_fn_prefix = 'url('

      body.dup.gsub(matcher) do |match|
        opening_character = $1
        asset_path = $2

        if asset_path.start_with?(url_fn_prefix)
          opening_character << url_fn_prefix
          asset_path = asset_path[url_fn_prefix.length..-1]
        end

        begin
          uri = ::Addressable::URI.parse(asset_path)

          if uri.relative? && uri.host.nil? && !(asset_path =~ /^[^\/].*[a-z]+\.[a-z]+\/.*/) && (result = yield(asset_path))
            "#{opening_character}#{result}"
          else
            match
          end
        rescue ::Addressable::URI::InvalidURIError
          match
        end
      end
    end
  end
end
