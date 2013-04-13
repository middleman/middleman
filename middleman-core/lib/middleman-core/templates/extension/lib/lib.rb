# Require core library
require "middleman-core"

# Extension namespace
module MyExtension < Middleman::Extension
  option :my_option, "default", "An example option"

  def initialize(app, options_hash={})
    # Call super to build options from the options_hash
    super

    # Require libraries only when activated
    # require 'necessary/library'

    # Include helpers or instance methods for the Middleman app
    # app.send :include, Helpers

    # set up your extension
    # puts options.my_option
  end

  def after_configuration
    # Do something
  end

  # module Helpers
  #   def a_helper
  #   end
  # end

end

# Register extensions which can be activated
# Make sure we have the version of Middleman we expect
# ::Middleman::Extensions.register(:extension_name) do
#
#   # Return the extension class
#   ::MyExtension
#
# end
