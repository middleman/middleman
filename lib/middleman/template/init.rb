# Helpers
helpers do
end

# Or inject more templating languages
# helpers Sinatra::Markdown

# Build-specific configuration
configure :build do
  Compass.configuration do |config|
    # For example, change the Compass output style for deployment
    # config.output_style = :compressed
    
    # Or use a different image path
    # config.http_images_path = "/Content/images/"
  end
end