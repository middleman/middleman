# =================================================================
# Compass Ruby on Rails Installer (template) v.1.0
# written by Derek Perez (derek@derekperez.com)
# -----------------------------------------------------------------
# NOTE: This installer is designed to work as a Rails template,
# and can only be used with Rails 2.3+.
# -----------------------------------------------------------------
# Copyright (c) 2009 Derek Perez
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
# =================================================================
puts "==================================================="
puts "Welcome to the Compass Installer for Ruby on Rails!"
puts "==================================================="
puts

# css framework prompt
css_framework = ask("What CSS Framework do you want to use with Compass? (default: 'blueprint')")
css_framework = "blueprint" if css_framework.blank?

# sass storage prompt
sass_dir = ask("Where would you like to keep your sass files within your project? (default: 'app/stylesheets')")
sass_dir = "app/stylesheets" if sass_dir.blank?

# compiled css storage prompt
css_dir = ask("Where would you like Compass to store your compiled css files? (default: 'public/stylesheets/compiled')")
css_dir = "public/stylesheets/compiled" if css_dir.blank?

# define dependencies
gem "haml", :lib => "haml", :version => ">=2.2.0"
gem "chriseppstein-compass", :source => "http://gems.github.com/", :lib => "compass"

# install and unpack
rake "gems:install GEM=haml", :sudo => true
rake "gems:install GEM=chriseppstein-compass", :sudo => true
rake "gems:unpack GEM=chriseppstein-compass"

# load any compass framework plugins
if css_framework =~ /960/
  gem "chriseppstein-compass-960-plugin", :source => "http://gems.github.com", :lib => "ninesixty"
  rake "gems:install GEM=chriseppstein-compass-960-plugin", :sudo => true
  rake "gems:unpack GEM=chriseppstein-compass-960-plugin"
  css_framework = "960" # rename for command
  plugin_require = "-r ninesixty"
end

# build out compass command
compass_command = "compass --rails -f #{css_framework} . --css-dir=#{css_dir} --sass-dir=#{sass_dir} "
compass_command << plugin_require if plugin_require

# Require compass during plugin loading
file 'vendor/plugins/compass/init.rb', <<-CODE
# This is here to make sure that the right version of sass gets loaded (haml 2.2) by the compass requires.
require 'compass'
CODE

# integrate it!
run "haml --rails ."
run compass_command

puts "Compass (with #{css_framework}) is all setup, have fun!"