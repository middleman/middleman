# Local templates
class Middleman::Templates::Local < Middleman::Templates::Base
  # Look for templates inside .middleman in the user's home directory 
  # @return [String]
  def self.source_root
    File.join(Dir.home, '.middleman')
  end

  # Just copy from the template path
  # @return [void]
  def build_scaffold!
    directory options[:template].to_s, location
  end
end

# Register this template
Middleman::Templates.register(:local, Middleman::Templates::Local)
