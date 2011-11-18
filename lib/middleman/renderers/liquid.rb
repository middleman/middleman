module Middleman::Renderers::Liquid
  class << self
    def registered(app)
      # Liquid is not included in the default gems,
      # but we'll support it if necessary.
      begin
        require "liquid"
        
        app.after_configuration do
          Liquid::Template.file_system = Liquid::LocalFileSystem.new(self.source_dir)
            
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