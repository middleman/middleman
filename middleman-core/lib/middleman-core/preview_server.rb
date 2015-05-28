require 'webrick'
require 'webrick/https'
require 'openssl'
require 'socket'
require 'middleman-core/meta_pages'
require 'middleman-core/logger'

# rubocop:disable GlobalVars
module Middleman
  module PreviewServer
    class << self
      attr_reader :app, :host, :port, :ssl_certificate, :ssl_private_key, :environment
      delegate :logger, to: :app

      def https?
        @https
      end

      # Start an instance of Middleman::Application
      # @return [void]
      def start(opts={})
        @options = opts

        mount_instance(new_app)

        logger.debug %(== The Middleman is running in "#{environment}" environment)
        logger.info "== The Middleman is standing watch at #{uri} (#{uri(public_ip)})"
        logger.info "== Inspect your site configuration at #{uri + '__middleman'}"

        @initialized ||= false
        return if @initialized
        @initialized = true

        register_signal_handlers

        # Save the last-used @options so it may be re-used when
        # reloading later on.
        ::Middleman::Profiling.report('server_start')

        loop do
          @webrick.start

          # $mm_shutdown is set by the signal handler
          if $mm_shutdown
            shutdown
            exit
          elsif $mm_reload
            $mm_reload = false
            reload
          end
        end
      end

      # Detach the current Middleman::Application instance
      # @return [void]
      def stop
        begin
          logger.info '== The Middleman is shutting down'
        rescue
          # if the user closed their terminal STDOUT/STDERR won't exist
        end

        if @listener
          @listener.stop
          @listener = nil
        end
        unmount_instance
      end

      # Simply stop, then start the server
      # @return [void]
      def reload
        logger.info '== The Middleman is reloading'

        begin
          app = new_app
        rescue => e
          logger.error "Error reloading Middleman: #{e}\n#{e.backtrace.join("\n")}"
          logger.info '== The Middleman is still running the application from before the error'
          return
        end

        unmount_instance

        @webrick.shutdown
        @webrick = nil

        mount_instance(app)

        logger.info '== The Middleman has reloaded'
      end

      # Stop the current instance, exit Webrick
      # @return [void]
      def shutdown
        stop
        @webrick.shutdown
      end

      private

      def new_app
        opts = @options.dup

        server = ::Middleman::Application.server

        # Add in the meta pages application
        meta_app = Middleman::MetaPages::Application.new(server)
        server.map '/__middleman' do
          run meta_app
        end

        @app = server.inst do
          ::Middleman::Logger.singleton(
            opts[:debug] ? 0 : 1,
            opts[:instrumenting] || false
          )

          config[:environment] = opts[:environment].to_sym if opts[:environment]
          config[:port] = opts[:port] if opts[:port]
          config[:host] = opts[:host].presence || Socket.gethostname.tr(' ', '+')
          config[:https] = opts[:https] unless opts[:https].nil?
          config[:ssl_certificate] = opts[:ssl_certificate] if opts[:ssl_certificate]
          config[:ssl_private_key] = opts[:ssl_private_key] if opts[:ssl_private_key]
        end

        @host        = @app.config[:host]
        @port        = @app.config[:port]
        @https       = @app.config[:https]
        @environment = @app.config[:environment]

        @ssl_certificate = @app.config[:ssl_certificate]
        @ssl_private_key = @app.config[:ssl_private_key]

        @app
      end

      def start_file_watcher
        return if @listener || @options[:disable_watcher]

        # Watcher Library
        require 'listen'

        options = { force_polling: @options[:force_polling] }
        options[:latency] = @options[:latency] if @options[:latency]

        @listener = Listen.to(::Middleman::Util.current_directory, options) do |modified, added, removed|
          added_and_modified = (modified + added)

          # See if the changed file is config.rb or lib/*.rb
          if needs_to_reload?(added_and_modified + removed)
            $mm_reload = true
            @webrick.stop
          else
            wd = Pathname(::Middleman::Util.current_directory)

            added_and_modified.each do |path|
              relative_path = Pathname(path).relative_path_from(wd).to_s
              next if app.files.ignored?(relative_path)
              app.files.did_change(relative_path)
            end

            removed.each do |path|
              relative_path = Pathname(path).relative_path_from(wd).to_s
              next if app.files.ignored?(relative_path)
              app.files.did_delete(relative_path)
            end
          end
        end

        # Don't block this thread
        @listener.start
      end

      # Trap some interupt signals and shut down smoothly
      # @return [void]
      def register_signal_handlers
        %w(INT HUP TERM QUIT).each do |sig|
          next unless Signal.list[sig]

          Signal.trap(sig) do
            # Do as little work as possible in the signal context
            $mm_shutdown = true
            @webrick.stop
          end
        end
      end

      # Initialize webrick
      # @return [void]
      def setup_webrick(is_logging)
        http_opts = {
          Port: port,
          AccessLog: [],
          ServerName: host,
          DoNotReverseLookup: true
        }

        if https?
          http_opts[:SSLEnable] = true

          if ssl_certificate || ssl_private_key
            raise 'You must provide both :ssl_certificate and :ssl_private_key' unless ssl_private_key && ssl_certificate
            http_opts[:SSLCertificate] = OpenSSL::X509::Certificate.new File.read ssl_certificate
            http_opts[:SSLPrivateKey] = OpenSSL::PKey::RSA.new File.read ssl_private_key
          else
            # use a generated self-signed cert
            cert, key = create_self_signed_cert(1024, [['CN', host]], 'Middleman Preview Server')
            http_opts[:SSLCertificate] = cert
            http_opts[:SSLPrivateKey] = key
          end
        end

        if is_logging
          http_opts[:Logger] = FilteredWebrickLog.new
        else
          http_opts[:Logger] = ::WEBrick::Log.new(nil, 0)
        end

        attempts_left = 4
        tried_ports = []
        begin
          ::WEBrick::HTTPServer.new(http_opts)
        rescue Errno::EADDRINUSE
          logger.error "== Port #{port} is unavailable. Either close the instance of Middleman already running on #{port} or start this Middleman on a new port with: --port=#{unused_tcp_port}"
          exit(1)
        end
      end

      # Copy of https://github.com/nahi/ruby/blob/webrick_trunk/lib/webrick/ssl.rb#L39
      # that uses a different serial number each time the cert is generated in order to
      # avoid errors in Firefox. Also doesn't print out stuff to $stderr unnecessarily.
      def create_self_signed_cert(bits, cn, comment)
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
        cert.sign(rsa, OpenSSL::Digest::SHA1.new)

        [cert, rsa]
      end

      # Attach a new Middleman::Application instance
      # @param [Middleman::Application] app
      # @return [void]
      def mount_instance(app)
        @app = app

        @webrick ||= setup_webrick(@options[:debug] || false)

        start_file_watcher

        rack_app = app.class.to_rack_app
        @webrick.mount '/', ::Rack::Handler::WEBrick, rack_app
      end

      # Detach the current Middleman::Application instance
      # @return [void]
      def unmount_instance
        @webrick.unmount '/'
        @app = nil
      end

      # Whether the passed files are config.rb, lib/*.rb or helpers
      # @param [Array<String>] paths Array of paths to check
      # @return [Boolean] Whether the server needs to reload
      def needs_to_reload?(paths)
        relative_paths = paths.map do |p|
          Pathname(p).relative_path_from(Pathname(app.root)).to_s
        end

        match_against = [
          %r{^config\.rb$},
          %r{^lib/[^\.](.*)\.rb$},
          %r{^helpers/[^\.](.*)\.rb$}
        ]

        if @options[:reload_paths]
          @options[:reload_paths].split(',').each do |part|
            match_against << %r{^#{part}}
          end
        end

        relative_paths.any? do |path|
          match_against.any? do |matcher|
            path =~ matcher
          end
        end
      end

      # Returns the URI the preview server will run on
      # @return [URI]
      def uri(host=@host)
        scheme = https? ? 'https' : 'http'
        URI("#{scheme}://#{host}:#{@port}/")
      end

      # An IPv4 address on this machine which should be externally addressable.
      # @return [String]
      def public_ip
        ip = Socket.ip_address_list.find { |ai| ai.ipv4? && !ai.ipv4_loopback? }
        ip ? ip.ip_address : '127.0.0.1'
      end

      # Returns unused TCP port
      # @return [Fixnum]
      def unused_tcp_port
        server = TCPServer.open(0)
        port = server.addr[1]
        server.close
        port
      end
    end

    class FilteredWebrickLog < ::WEBrick::Log
      def log(level, data)
        super(level, data) unless data =~ %r{Could not determine content-length of response body.}
      end
    end
  end
end
