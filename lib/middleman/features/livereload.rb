class Middleman::Features::LiveReload
  def initialize(app)
    return unless Middleman::Base.environment == :development
    
    begin
      require 'livereload'
    rescue LoadError
      puts "Livereload not available. Install it with: gem install livereload"
    end
  
    new_config = ::LiveReload::Config.new do |config|
      config.exts = %w(haml sass scss coffee less builder)
    end
  
    ::LiveReload.run [Middleman::Base.public, Middleman::Base.views], new_config
  end
end

Middleman::Features.register :livereload, Middleman::Features::LiveReload