require File.dirname(__FILE__) + '/../spec_helper'

describe String, '#strip_indentation!' do
  
  it "should remove unneccessary whitespace from the beginning of a line" do
    
    a_string = <<-STRING
      here be something
    STRING
    
    a_string.realign_indentation.should == <<-STRING
here be something
    STRING
    
  end
  
  it "should remove unneccessary whitespace from the beginning of all lines, but keep indentation" do
    
    a_string = <<-STRING
      here be something
        indented
          more
        blah
      test
        gurr
    STRING
    
    a_string.realign_indentation.should == <<-STRING
here be something
  indented
    more
  blah
test
  gurr
    STRING
    
  end
  
end