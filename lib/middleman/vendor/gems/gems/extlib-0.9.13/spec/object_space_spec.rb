require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

describe ObjectSpace, "#classes" do
  it 'returns only classes, nothing else' do
    ObjectSpace.classes.each do |klass|
      Class.should === klass
    end
  end
end
