require 'spec_helper'
require 'middleman-core/dependencies'

describe ::Middleman::Dependencies do
  describe '.load_and_deserialize' do
    let(:config) { { data_collection_depth: 1 } }
    let(:app) { double(:app, config: config) }

    context 'when the file is missing' do
      before do
        allow(File).to receive(:exist?).and_return(false)
      end

      it 'raises MissingDepsYAML' do
        expect { described_class.load_and_deserialize(app) }
          .to raise_error(described_class::MissingDepsYAML)
      end
    end

    context 'when the file is present' do
      let(:data) { { 'data_depth' => 1 } }

      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(described_class).to receive(:parse_yaml).and_return(data)
      end

      context 'when the data is invalid' do
        let(:data) { 1 }

        it 'raises InvalidDepsYAML' do
          expect { described_class.load_and_deserialize(app) }
            .to raise_error(described_class::InvalidDepsYAML)
        end
      end

      context 'when the depth is different to that in the config' do
        let(:config) { { data_collection_depth: 0 } }

        it 'raises ChangedDepth' do
          expect { described_class.load_and_deserialize(app) }
            .to raise_error(described_class::ChangedDepth)
        end
      end

      context 'when global files have been invalidated' do
        before do
          allow(described_class).to receive(:invalidated_global).and_return([1])
        end

        it 'raises InvalidatedGlobalFiles' do
          expect { described_class.load_and_deserialize(app) }
            .to raise_error(described_class::InvalidatedGlobalFiles)
        end
      end
    end
  end
end
