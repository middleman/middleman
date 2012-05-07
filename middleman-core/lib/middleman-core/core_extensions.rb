# Rack Request
require "middleman-core/core_extensions/request"

# File Change Notifier
require "middleman-core/core_extensions/file_watcher"

# Add Builder callbacks
require "middleman-core/core_extensions/builder"

# Custom Feature API
require "middleman-core/core_extensions/extensions"

# Asset Path Pipeline
require "middleman-core/core_extensions/assets"

# Data looks at the data/ folder for YAML files and makes them available
# to dynamic requests.
require "middleman-core/core_extensions/data"

# Parse YAML from templates
require "middleman-core/core_extensions/front_matter"

# External helpers looks in the helpers/ folder for helper modules
require "middleman-core/core_extensions/external_helpers"

# DefaultHelpers are the built-in dynamic template helpers.
require "middleman-core/core_extensions/default_helpers"

# Extended version of Padrino's rendering
require "middleman-core/core_extensions/rendering"

# Pass custom options to views
require "middleman-core/core_extensions/routing"

# Catch and show exceptions at the Rack level
require "middleman-core/core_extensions/show_exceptions"

# i18n
require "middleman-core/core_extensions/i18n"