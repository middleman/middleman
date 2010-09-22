module Middleman::Features::LiveReload
  class << self
    def registered(app)
      return unless Middleman::Server.environment == :development

      begin
        require 'livereload'
      rescue LoadError
        puts "Livereload not available. Install it with: gem install livereload"
      end

      new_config = ::LiveReload::Config.new do |config|
        config.exts = ::Tilt.mappings.keys
      end

      # Middleman::Server.public
      ::LiveReload.run [Middleman::Server.views], new_config
    end
    alias :included :registered
  end
end