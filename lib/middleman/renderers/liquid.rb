module Middleman::Renderers::Liquid
  class << self
    def registered(app)
      # Liquid is not included in the default gems,
      # but we'll support it if necessary.
      begin
        require "liquid"
        
        app.after_configuration do
          full_path = app.views
          full_path = File.join(app.root, app.views) unless app.views.include?(app.root)
          
          Liquid::Template.file_system = Liquid::LocalFileSystem.new(full_path)
            
          app.before_processing(:liquid) do |result|
            if result && result[1] == :liquid
              request['custom_locals'] ||= {}
              request['custom_locals'][:data] = data.to_h
            end

            true
          end
        end
      rescue LoadError
      end
    end
    alias :included :registered
  end
end