require 'compass'

class Middleman::Templates::Compass < Middleman::Templates::Base
  def self.source_root
    # Middleman.templates_path
  end

  def build_scaffold
    # directory options[:template].to_s, location
  end  
end

$stderr.puts Compass::Frameworks::ALL.map { |f| f.name }.inspect

# Dir[File.join(Middleman.templates_path, "*")].each do |dir|
#   next unless File.directory?(dir)
#   Middleman::Templates.register(File.basename(dir).to_sym, Middleman::Templates::Local)
# end