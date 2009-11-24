require File.dirname(__FILE__) + '/spec_helper'

require 'templater/spec/helpers'

module Gens

  extend Templater::Manifold

  class Gen < Templater::Generator
    invoke :gen2
    invoke :gen3 do |g|
      g.new(destination_root, options, 'blah', 'monkey')
    end
    template 'blah.template', 'blah.txt'
    template 'test.template', 'test.txt'
    file 'arg.file', 'arg.txt'
  end
  add :gen, Gen
  
  class Gen2 < Templater::Generator
  end
  add :gen2, Gen2
  
  class Gen3 < Templater::Generator
    first_argument :name
    second_argument :country
  end
  add :gen3, Gen3
  
  class Gen4 < Templater::Generator
  end
  add :gen4, Gen4
end


describe Templater::Spec::Helpers, "#invoke" do
  
  include Templater::Spec::Helpers
  
  before do
    @instance = Gens::Gen.new('/tmp', {})
  end
  
  it "should match when the expected generator is listed as an invocation" do
    @instance.should invoke(Gens::Gen2)
  end
  
  it "should not match when the expected generator is not listed as an invocation" do
    @instance.should_not invoke(Gens::Gen4)
  end
  
  it "should match when the expected generator is listed as an invocation with a block" do
    @instance.should invoke(Gens::Gen3)
  end
  
  it "should match when the expected generator, and its arguments are listed as an invocation" do
    @instance.should invoke(Gens::Gen3).with('blah', 'monkey')
  end
  
  it "should match when the expected generator is listed as an invocation with different arguments" do
    @instance.should_not invoke(Gens::Gen3).with('ape')
  end
end

describe Templater::Spec::Helpers, "#create" do
  
  include Templater::Spec::Helpers
  
  before do
    @instance = Gens::Gen.new(tmp('tmp'), {})
    @instance.stub!(:source_root).and_return('/source')
  end
  
  it "should match when the generator has a template with the expected destination" do
    @instance.should create(tmp('/tmp/blah.txt'))
  end
  
  it "should match when the generator has a file with the expected destination" do
    @instance.should create(tmp('/tmp/arg.txt'))
  end
  
  it "should match when the generator has neither a file nor a template with the expected destination" do
    @instance.should_not create(tmp('/tmp/blurns.txt'))
  end
end