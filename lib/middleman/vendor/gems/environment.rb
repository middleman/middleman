require 'rbconfig'
engine  = defined?(RUBY_ENGINE) ? RUBY_ENGINE : 'ruby'
version = Config::CONFIG['ruby_version']
require File.expand_path("../#{engine}/#{version}/environment", __FILE__)
