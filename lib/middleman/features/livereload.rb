module Middleman::Features::LiveReload
  def initialize(app, config)
    return unless Middleman::Server.environment == :development
    
    begin
      require 'livereload'
    rescue LoadError
      puts "Livereload not available. Install it with: gem install livereload"
    end
  
    new_config = ::LiveReload::Config.new do |config|
      config.exts = %w(haml sass scss coffee less builder)
    end
  
    ::LiveReload.run [Middleman::Server.public, Middleman::Server.views], new_config
  end
end

Middleman::Features.register :livereload, Middleman::Features::LiveReload