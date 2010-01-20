%w(manifest template_context base manifest_installer bare_installer).each do |f|
  require "compass/installers/#{f}"
end
