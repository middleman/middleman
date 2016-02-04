import_file File.expand_path("static.html", root), "/static2.html"

import_path File.expand_path("bower_components/", root)

import_path File.expand_path("bower_components", root) do |target_path, original_path|
  target_path.sub('bower_components', 'bower_components2')
end


# scenario: import renderable files
import_file File.join(__dir__, 'import_file_dir', 'import.html.md'),
            'import.html'

import_file File.join(__dir__, 'import_file_dir', 'import_with_frontmatter.html.erb'),
            'import_with_frontmatter.html'

# scenario: import renderable paths
import_path File.join(__dir__, 'import_path_dir') do |relative_path, full_path|
  File.join 'paths', relative_path.chomp(File.extname(relative_path)).sub(/^\/?import_path_dir\//, '')
end
