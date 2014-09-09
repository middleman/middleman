# A barebones template with nothing much in it
class Middleman::Templates::Empty < Middleman::Templates::Base
  # Template files are relative to this file
  # @return [String]
  def self.source_root
    File.dirname(__FILE__)
  end

  def self.gemfile_template
    'empty/Gemfile.tt'
  end

  # Actually output the files
  # @return [void]
  def build_scaffold!
    create_file File.join(location, 'config.rb'), "\n", force: options[:force]
    empty_directory File.join(location, 'source'), force: options[:force]
  end
end

# Register this template
Middleman::Templates.register(:empty, Middleman::Templates::Empty)
