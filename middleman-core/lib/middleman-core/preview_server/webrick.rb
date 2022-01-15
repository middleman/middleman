# frozen_string_literal: true

require 'openssl'
require 'webrick'
require 'webrick/https'

module Middleman
  class PreviewServer
    class Webrick
      attr_reader :webrick

      def initialize(rack_app, server_information, is_debug)
        @webrick = setup_webrick(server_information, is_debug)
        webrick.mount '/', ::Rack::Handler::WEBrick, rack_app
      end

      def start
        webrick.start
      end

      def shutdown!
        webrick.shutdown
        @webrick = nil
      end

      private

      def setup_webrick(server_information, is_debug)
        http_opts = {
          Port: server_information.port,
          AccessLog: [],
          ServerName: server_information.server_name,
          BindAddress: server_information.bind_address.to_s,
          DoNotReverseLookup: true
        }

        if server_information.https?
          http_opts[:SSLEnable] = true

          if ssl_certificate || ssl_private_key
            raise 'You must provide both :ssl_certificate and :ssl_private_key' unless ssl_private_key && ssl_certificate

            http_opts[:SSLCertificate] = OpenSSL::X509::Certificate.new ::File.read ssl_certificate
            http_opts[:SSLPrivateKey] = OpenSSL::PKey::RSA.new ::File.read ssl_private_key
          else
            # use a generated self-signed cert
            http_opts[:SSLCertName] = [
              %w[CN localhost],
              ['CN', server_information.server_name]
            ].uniq
            cert, key = create_self_signed_cert(4096, [['CN', server_information.server_name]], server_information.site_addresses, 'Middleman Preview Server')
            http_opts[:SSLCertificate] = cert
            http_opts[:SSLPrivateKey] = key
          end
        end

        http_opts[:Logger] = if is_debug
                               FilteredWebrickLog.new
                             else
                               ::WEBrick::Log.new(nil, 0)
                             end

        begin
          ::WEBrick::HTTPServer.new(http_opts)
        rescue Errno::EADDRINUSE
          port = http_opts[:Port]
          warn %(== Port #{port} is already in use. This could mean another instance of middleman is already running. Please make sure port #{port} is free and start `middleman server` again, or choose another port by running `middleman server —-port=#{port + 1}` instead.)
        end
      end

      # Copy of https://github.com/nahi/ruby/blob/webrick_trunk/lib/webrick/ssl.rb#L39
      # that uses a different serial number each time the cert is generated in order to
      # avoid errors in Firefox. Also doesn't print out stuff to $stderr unnecessarily.
      def create_self_signed_cert(bits, cn, aliases, comment)
        rsa = OpenSSL::PKey::RSA.new(bits)
        cert = OpenSSL::X509::Certificate.new
        cert.version = 2
        cert.serial = Time.now.to_i % (1 << 20)
        name = OpenSSL::X509::Name.new(cn)
        cert.subject = name
        cert.issuer = name
        cert.not_before = Time.now
        cert.not_after = Time.now + (365 * 24 * 60 * 60)
        cert.public_key = rsa.public_key

        ef = OpenSSL::X509::ExtensionFactory.new(nil, cert)
        ef.issuer_certificate = cert
        cert.extensions = [
          ef.create_extension('basicConstraints', 'CA:FALSE'),
          ef.create_extension('keyUsage', 'keyEncipherment'),
          ef.create_extension('subjectKeyIdentifier', 'hash'),
          ef.create_extension('extendedKeyUsage', 'serverAuth'),
          ef.create_extension('nsComment', comment)
        ]
        aki = ef.create_extension('authorityKeyIdentifier',
                                  'keyid:always,issuer:always')
        cert.add_extension(aki)
        cert.add_extension ef.create_extension('subjectAltName', aliases.map { |d| "DNS: #{d}" }.join(','))

        cert.sign(rsa, OpenSSL::Digest.new('SHA256'))

        [cert, rsa]
      end

      class FilteredWebrickLog < ::WEBrick::Log
        def log(level, data)
          super(level, data) unless /Could not determine content-length of response body./.match?(data)
        end
      end
    end
  end
end
