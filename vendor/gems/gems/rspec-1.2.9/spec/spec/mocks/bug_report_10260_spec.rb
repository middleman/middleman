require 'spec_helper'

describe "An RSpec Mock" do
  it "should hide internals in its inspect representation" do
    m = mock('cup')
    m.inspect.should =~ /#<Spec::Mocks::Mock:0x[a-f0-9.]+ @name="cup">/
  end
end
