# Middleman is a static site renderer that provides all the conveniences of
# a modern web stack, like Ruby on Rails, while remaining focused on building
# the fastest, most-professional sites possible
#
# Install Middleman:
#
#     gem install middleman
#
# To accomplish its goals, Middleman supports provides access to:
# 
#### Command-line tools:
# * **mm-init**: A tool for creating to new static sites.
# * **mm-server**: A tool for rapidly developing your static site.
# * **mm-build**: A tool for exporting your site into optimized HTML, CSS & JS.
#
#### Tons of templating languages including:
# * ERB                        (.erb)
# * Interpolated String        (.str)
# * Sass                       (.sass)
# * Scss                       (.scss)
# * Haml                       (.haml)
# * Slim                       (.slim)
# * Less CSS                   (.less)
# * Builder                    (.builder)
# * Liquid                     (.liquid)
# * RDiscount                  (.markdown)
# * RedCloth                   (.textile)
# * RDoc                       (.rdoc)
# * Radius                     (.radius)
# * Markaby                    (.mab)
# * Nokogiri                   (.nokogiri)
# * Mustache                   (.mustache)
# * CoffeeScript               (.coffee)
#
#### Compile-time Optimiztions
# * Javascript Minifiers: YUI, Google Closure & UglifyJS
# * Smush.it Image Compression
# * CSS Minification
#
#### Robust Extensions:
# Add your own runtime and build-time features!
#
#### Next Steps:
# * [Visit the website]
# * [Read the wiki]
# * [Email the users group]
# * [Submit bug reports]
#
# [Visit the website]:     http://middlemanapp.com
# [Read the wiki]:         https://github.com/tdreyno/middleman/wiki
# [Email the users group]: http://groups.google.com/group/middleman-users
# [Submit bug reports]:    https://github.com/tdreyno/middleman/issues

# Setup out load paths
libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

# Require Rubygems (probably not necessary)
require 'rubygems'

# Top-level Middleman object
module Middleman
  # Auto-load modules on-demand
  autoload :Server, "middleman/server"
  
  # Custom Renderers
  module Renderers
    autoload :Haml, "middleman/renderers/haml"
    autoload :Sass, "middleman/renderers/sass"
    autoload :Slim, "middleman/renderers/slim"
    autoload :Markdown, "middleman/renderers/markdown"
    autoload :CoffeeScript, "middleman/renderers/coffee_script"
  end

  # Features API
  autoload :Features, "middleman/features"
end
