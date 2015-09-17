require 'spec_helper'
require 'middleman-core/dns_resolver'

RSpec.describe Middleman::DnsResolver do
  subject(:resolver) do
    described_class.new(
      hosts_resolver: hosts_resolver,
      local_link_resolver: local_link_resolver,
      network_resolver: network_resolver
    )
  end

  let(:hosts_resolver) { instance_double('Middleman::DnsResolver::HostsResolver') }
  let(:local_link_resolver) { instance_double('Middleman::DnsResolver::LocalLinkResolver') }
  let(:network_resolver) { instance_double('Middleman::DnsResolver::NetworkResolver') }

  before :each do
    allow(network_resolver).to receive(:timeouts=)
  end

  describe '#names_for' do
    context 'when hosts resolver can resolve name' do
      before :each do
        expect(hosts_resolver).to receive(:getnames).with(unresolved_ip).and_return(resolved_names)
        if RUBY_VERSION >= '2.1'
          expect(local_link_resolver).not_to receive(:getnames)
        end
        expect(network_resolver).not_to receive(:getnames)
      end

      let(:unresolved_ip) { '127.0.0.1' }
      let(:resolved_names) { %w(localhost) }

      it { expect(resolver.names_for(unresolved_ip)).to eq resolved_names }
    end

    context 'when local link resolver can resolve name' do
      before :each do
        expect(hosts_resolver).to receive(:getnames).with(unresolved_ip).and_return([])
        if RUBY_VERSION >= '2.1'
          expect(local_link_resolver).to receive(:getnames).with(unresolved_ip).and_return(resolved_names)
          expect(network_resolver).not_to receive(:getnames)
        else
          expect(network_resolver).to receive(:getnames).with(unresolved_ip).and_return(resolved_names)
        end
      end

      let(:unresolved_ip) { '127.0.0.1' }
      let(:resolved_names) { %w(localhost) }

      it { expect(resolver.names_for(unresolved_ip)).to eq resolved_names }
    end

    context 'when network resolver can resolve name' do
      before :each do
        expect(hosts_resolver).to receive(:getnames).with(unresolved_ip).and_return([])
        if RUBY_VERSION >= '2.1'
          expect(local_link_resolver).to receive(:getnames).with(unresolved_ip).and_return([])
        end
        expect(network_resolver).to receive(:getnames).with(unresolved_ip).and_return(resolved_names)
      end

      let(:unresolved_ip) { '127.0.0.1' }
      let(:resolved_names) { %w(localhost) }

      it { expect(resolver.names_for(unresolved_ip)).to eq resolved_names }
    end
  end

  describe '#ips_for' do
    context 'when hosts resolver can resolve name' do
      before :each do
        expect(hosts_resolver).to receive(:getaddresses).with(unresolved_ips).and_return(resolved_name)
        if RUBY_VERSION >= '2.1'
          expect(local_link_resolver).not_to receive(:getaddresses)
        end
        expect(network_resolver).not_to receive(:getaddresses)
      end

      let(:unresolved_ips) { '127.0.0.1' }
      let(:resolved_name) { %w(localhost) }

      it { expect(resolver.ips_for(unresolved_ips)).to eq resolved_name }
    end

    context 'when local link resolver can resolve name' do
      before :each do
        expect(hosts_resolver).to receive(:getaddresses).with(unresolved_ips).and_return([])
        if RUBY_VERSION >= '2.1'
          expect(local_link_resolver).to receive(:getaddresses).with(unresolved_ips).and_return(resolved_name)
          expect(network_resolver).not_to receive(:getaddresses)
        else
          expect(network_resolver).to receive(:getaddresses).with(unresolved_ips).and_return(resolved_name)
        end
      end

      let(:unresolved_ips) { '127.0.0.1' }
      let(:resolved_name) { %w(localhost) }

      it { expect(resolver.ips_for(unresolved_ips)).to eq resolved_name }
    end

    context 'when network resolver can resolve name' do
      before :each do
        expect(hosts_resolver).to receive(:getaddresses).with(unresolved_ips).and_return([])
        if RUBY_VERSION >= '2.1'
          expect(local_link_resolver).to receive(:getaddresses).with(unresolved_ips).and_return([])
        end
        expect(network_resolver).to receive(:getaddresses).with(unresolved_ips).and_return(resolved_name)
      end

      let(:unresolved_ips) { '127.0.0.1' }
      let(:resolved_name) { %w(localhost) }

      it { expect(resolver.ips_for(unresolved_ips)).to eq resolved_name }
    end
  end
end
