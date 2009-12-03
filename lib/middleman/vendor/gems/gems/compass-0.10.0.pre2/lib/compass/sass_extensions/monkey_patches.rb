%w(stylesheet_updating traversal).each do |patch|
  require "compass/sass_extensions/monkey_patches/#{patch}"
end
