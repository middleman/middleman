# Liquid Renderer
module Middleman::Renderers::Liquid
  
  # Setup extension
  class << self
    
    # Once registerd
    def registered(app)
      # Liquid is not included in the default gems,
      # but we'll support it if available.
      begin
        
        # Require Gem
        require "liquid"
        
        app.before_configuration do
          template_extensions :liquid => :html
        end
        
        # After config, setup liquid partial paths
        app.after_configuration do
          Liquid::Template.file_system = Liquid::LocalFileSystem.new(source_dir)
            
          # Convert data object into a hash for liquid
          provides_metadata %r{\.liquid$} do |path|
            { :locals => { :data => data.to_h } }
          end
        end
      rescue LoadError
      end
    end
    
    alias :included :registered
  end
end