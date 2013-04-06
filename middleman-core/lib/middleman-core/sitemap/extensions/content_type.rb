require 'rack'

module Middleman::Sitemap::Extensions
  # Content type is implemented as a module so it can be overridden by other sitemap extensions
  module ContentType
    # The preferred MIME content type for this resource
    def content_type
      # Allow explcitly setting content type from page/proxy options
      meta_type = metadata[:options][:content_type]
      return meta_type if meta_type

      # Look up mime type based on extension
      ::Rack::Mime.mime_type(ext, nil)
    end
  end
end
