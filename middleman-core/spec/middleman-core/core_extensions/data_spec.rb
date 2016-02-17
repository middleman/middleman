require 'spec_helper'
require 'middleman-core/core_extensions'
require 'middleman-core/core_extensions/data'

describe Middleman::CoreExtensions::Data do
end

describe Middleman::CoreExtensions::Data::DataStore do

  describe "#store" do
    before :each do
      @subject = described_class.new instance_double("Middleman::Application"),
                                     Middleman::CoreExtensions::Data::DATA_FILE_MATCHER
    end

    context "when given a name and data" do
      it "adds data at the given name" do
        @subject.store :foo, { 'bar' => 'baz' }
        @subject.store :baz, [:wu, :tang]

        expect( @subject.store['foo'] ).to eq({ 'bar' => 'baz' })
        expect( @subject.store['baz'] ).to match_array [:wu, :tang]
      end

      it "overwrites previous keys if given the same key" do
        @subject.store :foo, { 'bar' => 'baz' }
        @subject.store :foo, [:wu, :tang]

        expect( @subject.store['foo'] ).to match_array [:wu, :tang]
      end
    end

    context "when given no args" do
      it "returns @local_sources instance var" do
        @subject.instance_variable_set :"@local_sources", { foo: 'bar' }
        expect( @subject.store ).to eq({ foo: 'bar' })
      end
    end
  end

  describe "#callbacks" do
    before :each do
      @subject = described_class.new instance_double("Middleman::Application"),
                                     Middleman::CoreExtensions::Data::DATA_FILE_MATCHER
    end

    context "when given a name and proc" do
      it "adds a callback at the given name" do
        @subject.callbacks :foo, lambda { "bar" }
        callback = @subject.instance_variable_get(:@callback_sources)['foo']

        expect( callback.call ).to eq "bar"
      end

      it "overwrites previous keys if given the same key" do
        @subject.callbacks :foo, lambda { "bar" }
        @subject.callbacks :foo, lambda { "baz" }
        callback = @subject.instance_variable_get(:@callback_sources)['foo']

        expect( callback.call ).to eq "baz"
      end
    end

    context "when given no args" do
      it "returns @callback_sources instance var" do
        @subject.instance_variable_set :"@callback_sources", { foo: 'bar' }
        expect( @subject.callbacks ).to eq({ foo: 'bar' })
      end
    end
  end

  describe "#data_for_path" do
    before :each do
      @subject = described_class.new instance_double("Middleman::Application"),
                                     Middleman::CoreExtensions::Data::DATA_FILE_MATCHER
    end

    context "given path matches local data" do
      it "returns hash for key" do
        @subject.store :foo, { 'bar' => 'baz' }
        expect( @subject.data_for_path(:foo) ).to eq({ 'bar' => 'baz' })
      end

      it "returns array for key" do
        @subject.store :foo, [:bar, :baz]
        expect( @subject.data_for_path(:foo) ).to match_array [:bar, :baz]
      end
    end

    context "given path matches callback data" do
      it "returns value of calback lambda" do
        @subject.callbacks :foo, lambda { { 'bar' => 'baz' } }
        @subject.callbacks :wu, lambda { [:tang, :clan] }

        expect( @subject.data_for_path(:foo) ).to eq({ 'bar' => 'baz' })
        expect( @subject.data_for_path(:wu) ).to match_array [:tang, :clan]
      end
    end

    context "given path matches both sources" do
      it "returns match from local data" do
        @subject.store :foo, { 'local' => 'data' }
        @subject.callbacks :foo, lambda { { 'callback' => 'data' } }

        expect( @subject.data_for_path(:foo) ).to eq({ 'local' => 'data' })
      end
    end

    context "given path matches no sources" do
      it "returns nil" do
        expect( @subject.data_for_path(:missing) ).to be_nil
      end
    end
  end

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
