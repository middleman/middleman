ENV["TEST"] = "true"
ENV["AUTOLOAD_SPROCKETS"] = "false"

PROJECT_ROOT_PATH = File.dirname(File.dirname(File.dirname(__FILE__)))

core_root = File.expand_path("../../../../middleman-core/lib/middleman-core", __FILE__)

require core_root
require File.join(core_root, "step_definitions")
require File.join(PROJECT_ROOT_PATH, 'lib', 'middleman-more')
