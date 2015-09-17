require 'spec_helper'
require 'middleman-core/preview_server/server_ip_address'

RSpec.describe Middleman::PreviewServer::ServerIpAddress do
  subject(:ip_address) { described_class.new(string) }
  let(:string) { '127.0.0.1' }

  describe '#to_s' do
    context 'when ipv4' do
      let(:string) { '127.0.0.1' }
      it { expect(ip_address.to_s).to eq string }
    end

    context 'when ipv6' do
      context 'without suffix' do
        let(:string) { '2607:f700:8000:12e:b3d9:1cba:b52:aa1b' }
        it { expect(ip_address.to_s).to eq string }
      end

      context 'with suffix' do
        let(:string) { '2607:f700:8000:12e:b3d9:1cba:b52:aa1b%wlp1s0' }
        let(:result) { '2607:f700:8000:12e:b3d9:1cba:b52:aa1b' }
        it { expect(ip_address.to_s).to eq result }
      end
    end
  end

  describe '#to_browser' do
    context 'when ip_address' do
      it { expect(ip_address.to_browser).to eq string }
    end

    context 'when ipv4' do
      let(:string) { '127.0.0.1' }
      it { expect(ip_address.to_browser).to eq string }
    end

    context 'when ipv6' do
      let(:string) { '2607:f700:8000:12e:b3d9:1cba:b52:aa1b' }
      it { expect(ip_address.to_browser).to eq "[#{string}]" }
    end
  end
end
