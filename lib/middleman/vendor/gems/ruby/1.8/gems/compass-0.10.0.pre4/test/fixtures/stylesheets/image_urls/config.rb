# Require any additional compass plugins here.
project_type = :stand_alone
css_dir = "tmp"
sass_dir = "sass"
images_dir = "images"
output_style = :compact
# To enable relative image paths using the images_url() function:
# http_images_path = :relative
http_images_path = "/images"

asset_cache_buster do |path, file|
  "busted=true"
end

asset_host do |path|
  "http://assets%d.example.com" % (path.hash % 4)
end
