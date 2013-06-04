module Padrino
  module Flash

    class << self
      # @private
      def registered(app)
        app.helpers Helpers
        app.after do
          session[:_flash] = @_flash.next if @_flash
        end
      end
    end # self

    class Storage
      include Enumerable

      # @private
      def initialize(session=nil)
        @_now  = session || {}
        @_next = {}
      end

      def now
        @_now
      end

      def next
        @_next
      end

      # @since 0.10.8
      # @api public
      def [](type)
        @_now[type]
      end

      # @since 0.10.8
      # @api public
      def []=(type, message)
        @_next[type] = message
      end

      # @since 0.10.8
      # @api public
      def delete(type)
        @_now.delete(type)
        self
      end

      # @since 0.10.8
      # @api public
      def keys
        @_now.keys
      end

      # @since 0.10.8
      # @api public
      def key?(type)
        @_now.key?(type)
      end

      # @since 0.10.8
      # @api public
      def each(&block)
        @_now.each(&block)
      end

      # @since 0.10.8
      # @api public
      def replace(hash)
        @_now.replace(hash)
        self
      end

      # @since 0.10.8
      # @api public
      def update(hash)
        @_now.update(hash)
        self
      end
      alias_method :merge!, :update

      # @since 0.10.8
      # @api public
      def sweep
        @_now.replace(@_next)
        @_next = {}
        self
      end

      # @since 0.10.8
      # @api public
      def keep(key = nil)
        if key
          @_next[key] = @_now[key]
        else
          @_next.merge!(@_now)
        end
        self
      end

      # @since 0.10.8
      # @api public
      def discard(key = nil)
        if key
          @_next.delete(key)
        else
          @_next = {}
        end
        self
      end

      # @since 0.10.8
      # @api public
      def clear
        @_now.clear
      end

      # @since 0.10.8
      # @api public
      def empty?
        @_now.empty?
      end

      # @since 0.10.8
      # @api public
      def to_hash
        @_now.dup
      end

      def length
        @_now.length
      end
      alias_method :size, :length

      # @since 0.10.8
      # @api public
      def to_s
        @_now.to_s
      end

      # @since 0.10.8
      # @api public
      def error=(message)
        self[:error] = message
      end

      # @since 0.10.8
      # @api public
      def error
        self[:error]
      end

      # @since 0.10.8
      # @api public
      def notice=(message)
        self[:notice] = message
      end

      # @since 0.10.8
      # @api public
      def notice
        self[:notice]
      end

      # @since 0.10.8
      # @api public
      def success=(message)
        self[:success] = message
      end

      # @since 0.10.8
      # @api public
      def success
        self[:success]
      end
    end # Storage

    module Helpers
      ###
      # Overloads the existing redirect helper in-order to provide support for flash messages
      #
      # @overload redirect(url)
      #   @param [String] url
      #
      # @overload redirect(url, status_code)
      #   @param [String] url
      #   @param [Fixnum] status_code
      #
      # @overload redirect(url, status_code, flash_messages)
      #   @param [String] url
      #   @param [Fixnum] status_code
      #   @param [Hash]   flash_messages
      #
      # @overload redirect(url, flash_messages)
      #   @param [String] url
      #   @param [Hash]   flash_messages
      #
      # @example
      #   redirect(dashboard, success: :user_created)
      #   redirect(new_location, 301, notice: 'This page has moved. Please update your bookmarks!!')
      #
      # @since 0.10.8
      # @api public
      def redirect(url, *args)
        flashes = args.extract_options!

        flashes.each do |type, message|
          message = I18n.translate(message) if message.is_a?(Symbol) && defined?(I18n)
          flash[type] = message
        end

        super(url, args)
      end
      alias_method :redirect_to, :redirect

      ###
      # Returns the flash storage object
      #
      # @return [Storage]
      #
      # @since 0.10.8
      # @api public
      def flash
        @_flash ||= Storage.new(env['rack.session'] ? session[:_flash] : {})
      end
    end # Helpers
  end # Flash
end # Padrino
