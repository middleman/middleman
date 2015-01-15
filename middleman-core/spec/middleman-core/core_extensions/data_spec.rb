require 'spec_helper'
require 'middleman-core/core_extensions'
require 'middleman-core/core_extensions/data'

describe Middleman::CoreExtensions::Data do
end

describe Middleman::CoreExtensions::Data::DataStore do

  describe "#key?" do

    it "returns true if key included in local_data, local_sources, or callback_sources" do
      subject = described_class.new instance_double("Middleman::Application"), Middleman::CoreExtensions::Data::DATA_FILE_MATCHER
      subject.store :"foo-store", { foo: "bar" }
      subject.callbacks :"foo-callback", Proc.new { "bar" }
      subject.instance_variable_get(:@local_data)["foo-local"] = "bar"

      expect( subject.key?("foo-store") ).to be_truthy
      expect( subject.key?("foo-callback") ).to be_truthy
      expect( subject.key?("foo-local") ).to be_truthy
    end

    it "returns false if key not in local_data, local_sources, or callback_sources" do
      subject = described_class.new instance_double("Middleman::Application"), Middleman::CoreExtensions::Data::DATA_FILE_MATCHER

      expect( subject.key?("foo-store") ).to be_falsy
      expect( subject.key?("foo-callback") ).to be_falsy
      expect( subject.key?("foo-local") ).to be_falsy
    end

    it "doesn't raise a stack error if missing the given key" do
      subject = described_class.new instance_double("Middleman::Application"), Middleman::CoreExtensions::Data::DATA_FILE_MATCHER

      expect{
        subject.respond_to? :test
      }.not_to raise_error
    end

  end

end