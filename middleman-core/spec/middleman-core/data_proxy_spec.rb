require 'spec_helper'
require 'middleman-core/data_proxy'
require 'middleman-core/template_context'

describe Middleman::DataProxy do
  describe '#data_proxy' do
    before :each do
      @subject = described_class.new instance_double('Middleman::TemplateContext')
      @raw_data = {
        name: 'Thomas',
        addresses: [
          { street: '1234 N Whatever' },
          { street: '4321 S Somewhere' }
        ]
      }
      @root_node = @subject.make_store(:people, @raw_data)
    end

    it 'should fully convert to proxies' do
      expect(@root_node).to be_kind_of(::Middleman::HashAccessProxy)
      expect(@root_node.addresses).to be_kind_of(::Middleman::ArrayAccessProxy)
      expect(@root_node.addresses[0]).to be_kind_of(::Middleman::HashAccessProxy)
      expect(@root_node.addresses[0].street).to be_kind_of(::String)
    end

    it 'should support indifferent access methods' do
      expect(@root_node.key?(:fake)).to be false
      expect(@root_node.key?(:name)).to be true
      expect(@root_node[:name]).to eq(@raw_data[:name])
      expect(@root_node['name']).to eq(@raw_data[:name])
      expect(@root_node.name).to eq(@raw_data[:name])
      expect(@root_node.fetch(:name, 'Fallback')).to eq(@raw_data[:name])
      expect(@root_node.fetch('name', 'Fallback')).to eq(@raw_data[:name])
      expect(@root_node.fetch(:derp, 'Fallback')).to eq('Fallback')
    end

    it 'logs first level of access' do
      # Access raw data at top level
      @root_node.name

      expect(@subject.accessed_keys.size).to eq(1)
      expect(@subject.accessed_keys).to include(%i[people name])

      # Should ignore this duplicate access
      @root_node.name
      @root_node['name']
      @root_node[:name]
      expect(@subject.accessed_keys.size).to eq(1)
    end

    it 'should log non-data access as requiring the entire object' do
      @root_node.size
      expect(@subject.accessed_keys.size).to eq(1)
      expect(@subject.accessed_keys).to include(%i[people __full_access__])

      @root_node.keys.map(&:to_s)
      expect(@subject.accessed_keys.size).to eq(1)

      # Didn't do anything with the data, so no access.
      @root_node.addresses
      expect(@subject.accessed_keys.size).to eq(1)

      @root_node.addresses.size
      expect(@subject.accessed_keys.size).to eq(2)
      expect(@subject.accessed_keys).to include(%i[people addresses __full_access__])
    end

    it 'logs sub hash access' do
      # Didn't do anything with the data, so no access.
      @root_node.addresses
      @root_node['addresses']
      @root_node[:addresses]
      expect(@subject.accessed_keys.size).to eq(0)

      expect(@subject.accessed_keys.size).to eq(0)

      # Should log secondary access
      @root_node.name
      expect(@subject.accessed_keys.size).to eq(1)
      expect(@subject.accessed_keys).to include(%i[people name])
    end

    it 'logs sub array access individually' do
      # Didn't do anything with the data, so no access.
      @root_node.addresses[0]
      expect(@subject.accessed_keys.size).to eq(0)

      @root_node.addresses[0].street
      expect(@subject.accessed_keys.size).to eq(1)
      expect(@subject.accessed_keys).to include([:people, :addresses, 0, :street])

      # First is same as index 0
      @root_node.addresses.first
      expect(@subject.accessed_keys.size).to eq(1)

      # First is same as index [size - 1]
      @root_node.addresses.last.street
      expect(@subject.accessed_keys.size).to eq(2)
      expect(@subject.accessed_keys).to include([:people, :addresses, @raw_data[:addresses].size - 1, :street])
    end

    it 'logs sub array access slices' do
      @root_node.addresses[0, 1]
      expect(@subject.accessed_keys.size).to eq(1)
      expect(@subject.accessed_keys).to include(%i[people addresses __full_access__])
    end
  end
end
