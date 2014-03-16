# A barebones template with nothing much in it
class Middleman::Templates::Empty < Middleman::Templates::Base
  # Template files are relative to this file
  # @return [String]
  def self.source_root
    File.dirname(__FILE__)
  end

  # Output the files
  # @return [void]
  def build_scaffold!
    template 'shared/config.tt', File.join(location, 'config.rb')
    empty_directory File.join(location, 'source')
    create_file File.join(location, 'source', '.gitkeep') unless options[:'skip-git']
  end
end

# Register this template
Middleman::Templates.register(:empty, Middleman::Templates::Empty)
