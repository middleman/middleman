require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/templater'

Hoe.plugin :newgem
# Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'templater' do
  self.developer 'Jonas Nicklas', 'jonas.nicklas@gmail.com'
  self.rubyforge_name       = self.name # TODO this is default value  
  self.extra_deps << ['highline', ">= 1.4.0"]
  self.extra_deps << ['diff-lcs', ">= 1.1.2"]
  self.extra_deps << ['extlib', ">= 0.9.5"]
  self.extra_dev_deps << ['rspec', '>= 1.2.8']
end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }
