libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

# Bundler
require File.join(File.dirname(libdir), "vendor", "gems", "environment")# if ENV["RUN_CODE_RUN"]
require 'middleman/base'