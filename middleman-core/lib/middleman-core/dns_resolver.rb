require 'resolv'
require 'middleman-core/dns_resolver/network_resolver'
require 'middleman-core/dns_resolver/hosts_resolver'

module Middleman
  # This resolves IP address to names and vice versa
  class DnsResolver
    private

    attr_reader :resolvers

    public

    # Create resolver
    #
    # First the local resolver is used. If environment variable HOSTSRC is
    # given this file is used for local name lookup.
    #
    # @param [#getnames, #getaddresses] network_resolver
    #   The resolver which uses a network name server to resolve ip addresses
    #   and names.
    #
    # @param [#getnames, #getaddresses] local_resolver
    #   The resolver uses /etc/hosts on POSIX-systems and
    #   C:\Windows\System32\drivers\etc\hosts on Windows-operating systems to
    #   resolve ip addresses and names.
    #
    # First the local resolver is queried. If this raises an error or returns
    # nil or [] the network resolver is queried.
    def initialize(opts={})
      @resolvers = []
      @resolvers << opts.fetch(:hosts_resolver, HostsResolver.new)

      if RUBY_VERSION >= '2.1'
        require 'middleman-core/dns_resolver/local_link_resolver'
        @resolvers << opts.fetch(:local_link_resolver, LocalLinkResolver.new)
      end

      @resolvers << opts.fetch(:network_resolver, NetworkResolver.new)
    end

    # Get names for given ip
    #
    # @param [String] ip
    #   The ip which should be resolved.
    def names_for(ip)
      resolvers.each do |r|
        names = r.getnames(ip)

        return names unless names.nil? || names.empty?
      end

      []
    end

    # Get ips for given name
    #
    # First the local resolver is used. On POSIX-systems /etc/hosts is used. On
    # Windows C:\Windows\System32\drivers\etc\hosts is used.
    #
    # @param [String] name
    #   The name which should be resolved.
    def ips_for(name)
      resolvers.each do |r|
        ips = r.getaddresses(name)

        return ips unless ips.nil? || ips.empty?
      end

      []
    end
  end
end
