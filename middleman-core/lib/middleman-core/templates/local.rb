# Local templates
class Middleman::Templates::Local < Middleman::Templates::Base
  # Look for templates in ~/.middleman
  # @return [String]
  def self.source_root
    File.join(File.expand_path('~/'), '.middleman')
  end

  # Just copy from the template path
  # @return [void]
  def build_scaffold!
    directory options[:template].to_s, location, force: options[:force], exclude_pattern: /\.git\/.*/
  end
end

# Iterate over the directories in the templates path and register each one.
Dir[File.join(Middleman::Templates::Local.source_root, '*')].each do |dir|
  next unless File.directory?(dir)

  template_file = File.join(dir, 'template.rb')

  if File.exist?(template_file)
    require template_file
  else
    Middleman::Templates.register(File.basename(dir).to_sym, Middleman::Templates::Local)
  end
end
