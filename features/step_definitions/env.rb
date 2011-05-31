ENV["MM_DIR"] = File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "fixtures", "test-app")
require File.join(File.dirname(File.dirname(File.dirname(__FILE__))), 'lib', 'middleman')
require "rack/test"

# absolute views path
# otherwise resolve_template (padrino-core) can't find templates
Before do
  Middleman::Server.views = File.join(Middleman::Server.root, "source")
end