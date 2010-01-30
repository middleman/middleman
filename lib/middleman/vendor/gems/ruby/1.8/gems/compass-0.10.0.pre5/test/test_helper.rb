need_gems = false

lib_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(lib_dir) unless $:.include?(lib_dir)
test_dir = File.dirname(__FILE__)
$:.unshift(test_dir) unless $:.include?(test_dir)

# allows testing with edge Haml by creating a test/haml symlink
linked_haml = File.dirname(__FILE__) + '/haml'

if File.exists?(linked_haml) && !$:.include?(linked_haml + '/lib')
  puts "[ using linked Haml ]"
  $:.unshift linked_haml + '/lib'
  require 'sass'
else
  need_gems = true
end

require 'rubygems' if need_gems

require 'compass'

require 'test/unit'

require 'test_case_helper'
require 'io_helper'
require 'rails_helper'
require 'command_line_helper'
