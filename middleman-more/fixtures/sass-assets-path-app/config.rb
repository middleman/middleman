
set :sass_assets_paths, [
  "#{root}/assets/stylesheets/", 
  # load from another app within gem source
  "#{File.dirname(File.dirname(File.dirname(File.dirname(__FILE__))))}/fixtures/preview-app/source/stylesheets/"
]