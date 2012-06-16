# Rack Request
require "middleman-core/core_extensions/request"

# File Change Notifier
require "middleman-core/core_extensions/file_watcher"

# Add Builder callbacks
require "middleman-core/core_extensions/builder"

# Custom Feature API
require "middleman-core/core_extensions/extensions"

# Data looks at the data/ folder for YAML files and makes them available
# to dynamic requests.
require "middleman-core/core_extensions/data"

# Parse YAML from templates
require "middleman-core/core_extensions/front_matter"

# External helpers looks in the helpers/ folder for helper modules
require "middleman-core/core_extensions/external_helpers"

# Extended version of Padrino's rendering
require "middleman-core/core_extensions/rendering"

# Pass custom options to views
require "middleman-core/core_extensions/routing"

# Catch and show exceptions at the Rack level
require "middleman-core/core_extensions/show_exceptions"

# Manage Ruby string encodings
require "middleman-core/core_extensions/ruby_encoding"
