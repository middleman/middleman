MIDDLEMAN_ROOT_PATH = File.dirname(File.dirname(File.dirname(__FILE__)))
MIDDLEMAN_BIN_PATH  = File.join(MIDDLEMAN_ROOT_PATH, "bin")
ENV['PATH'] = "#{MIDDLEMAN_BIN_PATH}#{File::PATH_SEPARATOR}#{ENV['PATH']}"

require "aruba/cucumber"
require "middleman-core/step_definitions/middleman_steps"
require "middleman-core/step_definitions/builder_steps"
require "middleman-core/step_definitions/server_steps"

Before do
  @aruba_timeout_seconds = 30
end
