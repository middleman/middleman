module Middleman::Features::CodeRay
  class << self
    def registered(app)
      begin
        require 'haml-coderay'
      rescue LoadError
        puts "CodeRay not available. Install it with: gem install haml-coderay"
      end
    end
    alias :included :registered
  end
end