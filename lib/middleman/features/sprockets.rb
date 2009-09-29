begin
  require 'sprockets'
  require 'middleman/features/sprockets+ruby19' # Sprockets ruby 1.9 duckpunch
rescue LoadError
  puts "Sprockets not available. Install it with: gem install sprockets"
end

module Middleman
  module Sprockets
    def render_path(path)
      source = File.join(options.public, path)
      if File.extname(path) == '.js' && File.exists?(source)
        secretary = ::Sprockets::Secretary.new( :asset_root   => options.public,
                                                :source_files => [source] )
        secretary.concatenation.to_s
      else
        super
      end
    end
  end
  
  class Base
    include Middleman::Sprockets
  end
end