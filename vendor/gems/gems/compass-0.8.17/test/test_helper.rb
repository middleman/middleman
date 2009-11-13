need_gems = false

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

require File.join(File.dirname(__FILE__), 'test_case_helper')
require File.join(File.dirname(__FILE__), 'command_line_helper')
