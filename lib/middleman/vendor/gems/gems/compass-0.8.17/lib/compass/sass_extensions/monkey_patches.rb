['stylesheet_updating'].each do |patch|
  require File.join(File.dirname(__FILE__), 'monkey_patches', patch)
end