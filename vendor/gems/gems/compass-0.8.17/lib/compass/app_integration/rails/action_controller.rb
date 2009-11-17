# :stopdoc:
module ActionController
  class Base
    def process_with_compass(*args)
      Sass::Plugin.rails_controller = self
      begin
        process_without_compass(*args)
      ensure
        Sass::Plugin.rails_controller = nil
      end
    end
    alias_method_chain :process, :compass
  end
end
# :startdoc: