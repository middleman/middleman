# Require core library
require "middleman-core"

# Extension namespace
module MyExtension
  class << self

    # Called when user `activate`s your extension
    def registered(app, options={})
      # Setup extension-specific config
      app.set :config_variable, false

      # Include class methods
      # app.extend ClassMethods

      # Include instance methods
      # app.send :include, InstanceMethods

      app.after_configuration do
        # Do something

        # config_variable is now either the default or the user's
        # setting from config.rb
      end
    end
    alias :included :registered
  end

  # module ClassMethods
  #   def a_class_method
  #   end
  # end

  # module InstanceMethods
  #   def an_instance_method
  #   end
  # end

end


# Register extensions which can be activated
# Make sure we have the version of Middleman we expect
# ::Middleman::Extensions.register(:extension_name) do
#
#   # Return the extension module
#   ::MyExtension
#
# end
