# Local templates
class Middleman::Templates::Local < Middleman::Templates::Base
  
  # Look for templates in ~/.middleman
  def self.source_root
    Middleman.templates_path
  end

  # Just copy from the template path
  def build_scaffold
    directory options[:template].to_s, location
  end  
end

# Iterate over the directories in the templates path and register each one.
Dir[File.join(Middleman.templates_path, "*")].each do |dir|
  next unless File.directory?(dir)
  Middleman::Templates.register(File.basename(dir).to_sym, Middleman::Templates::Local)
end
