##
# Manages current Padrino version for use in gem generation.
#
# We put this in a separate file so you can get padrino version
# without include full padrino core.
#
module Padrino
  VERSION = '0.10.0' unless defined?(Padrino::VERSION)
  ##
  # Return the current Padrino version
  #
  def self.version
    VERSION
  end
end # Padrino
