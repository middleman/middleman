require 'spec_helper'
require 'middleman-core/core_extensions/data/proxies/hash'
require 'middleman-core/util/data'

describe ::Middleman::CoreExtensions::Data::Proxies::HashProxy do
  describe '#data_proxy' do
    before :each do
      @raw_data = {
        name: 'Thomas',
        addresses: [
          { street: '1234 N Whatever' },
          { street: '4321 S Somewhere' }
        ]
      }
      @subject = described_class.new :people, ::Middleman::Util.recursively_enhance(@raw_data), ::Float::INFINITY
    end

    it 'should fully convert to proxies' do
      expect(@subject).to be_kind_of(::Middleman::CoreExtensions::Data::Proxies::HashProxy)
      expect(@subject.addresses).to be_kind_of(::Middleman::CoreExtensions::Data::Proxies::ArrayProxy)
      expect(@subject.addresses[0]).to be_kind_of(::Middleman::CoreExtensions::Data::Proxies::HashProxy)
      expect(@subject.addresses[0].street).to be_kind_of(::String)
    end

    it 'should support indifferent access methods' do
      expect(@subject.key?(:fake)).to be false
      expect(@subject.key?(:name)).to be true
      expect(@subject[:name]).to eq(@raw_data[:name])
      expect(@subject['name']).to eq(@raw_data[:name])
      expect(@subject.name).to eq(@raw_data[:name])
      expect(@subject.fetch(:name, 'Fallback')).to eq(@raw_data[:name])
      expect(@subject.fetch('name', 'Fallback')).to eq(@raw_data[:name])
      expect(@subject.fetch(:derp, 'Fallback')).to eq('Fallback')
    end

    it 'logs first level of access' do
      # Access raw data at top level
      @subject.name

      expect(@subject.accessed_keys.size).to eq(1)
      expect(@subject.accessed_keys).to include(%i[people name])

      # Should ignore this duplicate access
      @subject.name
      @subject['name']
      @subject[:name]
      expect(@subject.accessed_keys.size).to eq(1)
    end

    it 'should log non-data access as requiring the entire object' do
      @subject.size
      expect(@subject.accessed_keys.size).to eq(1)
      expect(@subject.accessed_keys).to include(%i[people __full_access__])

      @subject.keys.map(&:to_s)
      expect(@subject.accessed_keys.size).to eq(1)

      # Didn't do anything with the data, so no access.
      @subject.addresses
      expect(@subject.accessed_keys.size).to eq(1)

      @subject.addresses.size
      expect(@subject.accessed_keys.size).to eq(2)
      expect(@subject.accessed_keys).to include(%i[people addresses __full_access__])
    end

    it 'logs sub hash access' do
      # Didn't do anything with the data, so no access.
      @subject.addresses
      @subject['addresses']
      @subject[:addresses]
      expect(@subject.accessed_keys.size).to eq(0)

      expect(@subject.accessed_keys.size).to eq(0)

      # Should log secondary access
      @subject.name
      expect(@subject.accessed_keys.size).to eq(1)
      expect(@subject.accessed_keys).to include(%i[people name])
    end

    it 'logs sub array access individually' do
      # Didn't do anything with the data, so no access.
      @subject.addresses[0]
      expect(@subject.accessed_keys.size).to eq(0)

      @subject.addresses[0].street
      expect(@subject.accessed_keys.size).to eq(1)
      expect(@subject.accessed_keys).to include([:people, :addresses, 0, :street])

      # First is same as index 0
      @subject.addresses.first
      expect(@subject.accessed_keys.size).to eq(1)

      # First is same as index [size - 1]
      @subject.addresses.last.street
      expect(@subject.accessed_keys.size).to eq(2)
      expect(@subject.accessed_keys).to include([:people, :addresses, @raw_data[:addresses].size - 1, :street])
    end

    it 'logs sub array access slices' do
      @subject.addresses[0, 1]
      expect(@subject.accessed_keys.size).to eq(1)
      expect(@subject.accessed_keys).to include(%i[people addresses __full_access__])
    end
  end
end
