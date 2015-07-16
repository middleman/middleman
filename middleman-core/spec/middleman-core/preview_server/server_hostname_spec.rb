require 'spec_helper'
require 'middleman-core/preview_server/server_hostname'

RSpec.describe Middleman::PreviewServer::ServerHostname do
  subject(:hostname) { described_class.new(string) }
  let(:string) { 'www.example.com' }

  describe '#to_s' do
    context 'when hostname' do
      it { expect(hostname.to_s).to eq string }
    end

    context 'when ipv4' do
      let(:string) { '127.0.0.1' }
      it { expect(hostname.to_s).to eq string }
    end

    context 'when ipv6' do
      let(:string) { '2607:f700:8000:12e:b3d9:1cba:b52:aa1b' }
      it { expect(hostname.to_s).to eq string }
    end
  end

  describe '#to_browser' do
    context 'when hostname' do
      it { expect(hostname.to_browser).to eq string }
    end

    context 'when ipv4' do
      let(:string) { '127.0.0.1' }
      it { expect(hostname.to_browser).to eq string }
    end

    context 'when ipv6' do
      let(:string) { '::1' }
      it { expect(hostname.to_browser).to eq string }
    end
  end
end
