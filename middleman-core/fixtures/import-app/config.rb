import_file File.expand_path("static.html", root), "/static2.html"

import_path File.expand_path("bower_components/", root)

import_path File.expand_path("bower_components", root) do |target_path, original_path|
  target_path.sub('bower_components', 'bower_components2')
end
