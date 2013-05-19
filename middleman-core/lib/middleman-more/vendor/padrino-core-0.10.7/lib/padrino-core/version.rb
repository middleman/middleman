#
# Manages current Padrino version for use in gem generation.
#
# We put this in a separate file so you can get padrino version
# without include full padrino core.
#
module Padrino
  # The version constant for the current version of Padrino.
  VERSION = '0.10.7' unless defined?(Padrino::VERSION)

  #
  # The current Padrino version.
  #
  # @return [String]
  #   The version number.
  #
  def self.version
    VERSION
  end
end # Padrino
