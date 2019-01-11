
require 'spec_helper'
require 'middleman-core/core_extensions'
require 'middleman-core/core_extensions/data'

describe Middleman::CoreExtensions::Data::DataStoreController do
  describe '#store' do
    before :each do
      app = instance_double('Middleman::Application')
      allow(app).to receive(:config).and_return({
        data_collection_depth: ::Float::INFINITY
      })
      @subject = described_class.new(app, false)
    end

    context 'when given a name and data' do
      it 'adds data at the given name' do
        @subject.store :foo, 'bar' => 'baz'
        @subject.store :baz, %i[wu tang]

        expect(@subject.key?(:foo)).to be true
        expect(@subject.foo.to_h).to eq('bar' => 'baz')
        expect(@subject.foo.bar).to eq('baz')

        expect(@subject.key?(:baz)).to be true
        expect(@subject.baz.to_a).to match_array %i[wu tang]
      end

      it 'overwrites previous keys if given the same key' do
        @subject.store :foo, 'bar' => 'baz'
        @subject.store :foo, %i[wu tang]

        expect(@subject.foo.to_a).to match_array %i[wu tang]
      end
    end
  end

  describe '#callbacks' do
    before :each do
      app = instance_double('Middleman::Application')
      allow(app).to receive(:config).and_return({
        data_collection_depth: ::Float::INFINITY
      })
      @subject = described_class.new(app, false)
    end

    context 'when given a name and proc' do
      it 'adds a callback at the given name' do
        @subject.callbacks :foo, -> { ['bar'] }

        expect(@subject.key?(:foo)).to be true
        expect(@subject.foo[0]).to eq 'bar'
      end

      it 'overwrites previous keys if given the same key' do
        @subject.callbacks :foo, -> { ['bar'] }
        @subject.callbacks :foo, -> { ['baz'] }

        expect(@subject.foo[0]).to eq 'baz'
      end
    end
  end

  describe '#ordering' do
    before :each do
      app = instance_double('Middleman::Application')
      allow(app).to receive(:config).and_return({
        data_collection_depth: ::Float::INFINITY
      })
      @subject = described_class.new(app, false)
    end

    context 'given path matches local data' do
      it 'returns hash for key' do
        @subject.store :foo, 'bar' => 'baz'
        expect(@subject.foo.to_h).to eq('bar' => 'baz')
      end

      it 'returns array for key' do
        @subject.store :foo, %i[bar baz]
        expect(@subject.foo.to_a).to match_array %i[bar baz]
      end
    end

    context 'given path matches callback data' do
      it 'returns value of callback lambda' do
        @subject.callbacks :foo, -> { { 'bar' => 'baz' } }
        @subject.callbacks :wu, -> { %i[tang clan] }

        expect(@subject.foo.to_h).to eq('bar' => 'baz')
        expect(@subject.wu.to_a).to match_array %i[tang clan]
      end
    end

    context 'given path matches both sources' do
      it 'returns match from local data' do
        @subject.callbacks :foo, -> { { 'callback' => 'data' } }
        @subject.store :foo, 'local' => 'data'

        expect(@subject.foo.to_h).to eq('local' => 'data')
      end
    end
  end

  describe '#key?' do
    before :each do
      app = instance_double('Middleman::Application')
      allow(app).to receive(:config).and_return({
        data_collection_depth: ::Float::INFINITY
      })
      @subject = described_class.new(app, false)
    end

    it 'given path matches no sources returns false' do
      expect(@subject.key?(:missing)).to be false
    end

    it 'returns true if key included in local_data, local_sources, or callback_sources' do
      @subject.store :"foo-store", foo: 'bar'
      @subject.callbacks :"foo-callback", proc { ['bar'] }

      expect(@subject.key?(:'foo-store')).to be true
      expect(@subject.key?(:'foo-callback')).to be true
    end

    it 'returns false if key not in local_data, local_sources, or callback_sources' do
      expect(@subject.key?(:'foo-store')).to be false
      expect(@subject.key?(:'foo-callback')).to be false
      expect(@subject.key?(:'foo-local')).to be false
    end

    it "doesn't raise a stack error if missing the given key" do
      expect do
        @subject.respond_to? :test
      end.not_to raise_error
    end
  end
end
