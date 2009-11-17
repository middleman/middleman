require 'spec_helper'
require 'ruby_forker'

module TestUnitSpecHelper
  include RubyForker

  def resources
    File.dirname(__FILE__) + "/resources"
  end
  
  def run_script(file_name)
    output = ruby(file_name)
    if !$?.success? || output.include?("FAILED") || output.include?("Error")
      raise output
    end
    output
  end  
end