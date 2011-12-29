

require "coffee_script"
app.register Middleman::Renderers::Haml
app.register Middleman::Renderers::Sass
app.register Middleman::Renderers::Markdown
app.register Middleman::Renderers::Liquid


set :default_extensions, [
  :lorem
]



# Compass framework
register Middleman::CoreExtensions::Compass

# Sprockets asset handling
register Middleman::CoreExtensions::Sprockets

# Activate built-in helpers
register Middleman::CoreExtensions::DefaultHelpers


    Middleman::Extensions.register(:asset_host) { 
      Middleman::Extensions::AssetHost }
    Middleman::Extensions.register(:automatic_image_sizes) {
      Middleman::Extensions::AutomaticImageSizes }
    Middleman::Extensions.register(:cache_buster) { 
      Middleman::Extensions::CacheBuster }
    Middleman::Extensions.register(:lorem) { 
      Middleman::Extensions::Lorem }
    Middleman::Extensions.register(:minify_css) { 
      Middleman::Extensions::MinifyCss }
    Middleman::Extensions.register(:minify_javascript) {
      Middleman::Extensions::MinifyJavascript }
    Middleman::Extensions.register(:relative_assets) {
      Middleman::Extensions::RelativeAssets }