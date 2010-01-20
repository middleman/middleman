require 'spec/spec_helper'

describe Smusher::PunyPng do
  describe :optimized_image_data_for do
    it "loads the reduced image" do
      original = File.join(ROOT,'images','add.png')
      reduced = File.read(File.join(ROOT, 'reduced', 'add_puny.png'))
      received = Smusher::PunyPng.optimized_image_data_for(original)
      received.should == reduced
    end
  end
end