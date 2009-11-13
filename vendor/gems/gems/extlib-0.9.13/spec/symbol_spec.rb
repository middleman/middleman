require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

describe Symbol, "#/" do
  it "concanates operands with File::SEPARATOR" do
    (:merb / "core").should == "merb#{File::SEPARATOR}core"
    (:merb / :core).should == "merb#{File::SEPARATOR}core"
  end
end
