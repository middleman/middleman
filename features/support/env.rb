root_path = File.dirname(File.dirname(File.dirname(__FILE__)))
ENV["MM_DIR"] = File.join(root_path, "fixtures", "test-app")
require File.join(root_path, 'lib', 'middleman')
require "rack/test"