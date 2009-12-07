ENV["MM_DIR"] = File.join(File.dirname(__FILE__), "fixtures", "sample")
require File.join(File.dirname(File.dirname(__FILE__)), 'lib', 'middleman')
require 'spec'
require 'rack/test'

Spec::Runner.configure do |config|
  
end
