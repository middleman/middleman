require "sprockets"

module Middleman::CoreExtensions::Sprockets
  class << self
    def registered(app)
      # app.map '/assets' do
      #   run ::Sprockets::Environment.new
      # end
    end
    alias :included :registered
  end
  
  class Environment < Sprockets::Environment
  
    # Pass in the project you want the pipeline to manage.
    def initialize(app, mode = :debug)
      # Views/ ?
      super app.root

      # Disable css for now
      # unregister_processor "text/css", Sprockets::DirectiveProcessor

      # configure search paths
      # append_path File.dirname project_path
      # append_path File.join project_path, 'assets'
    end
    
  end
end