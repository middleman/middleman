require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

describe Extlib::ByteArray do
  it 'should be a String' do
    Extlib::ByteArray.new.should be_kind_of(String)
  end
end
