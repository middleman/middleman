require File.expand_path(File.dirname(__FILE__) + '/helper')
require 'lumberjack'
require 'logger'

describe "PadrinoLogger" do

  def setup
    Padrino::Logger::Config[:test][:stream] = :null # The default
    Padrino::Logger.setup!
  end

  def setup_logger(options={})
    @log    = StringIO.new
    @logger = Padrino::Logger.new(options.merge(:stream => @log))
  end

  context 'for logger functionality' do

    context 'check stream config' do

      should 'use stdout if stream is nil' do
        Padrino::Logger::Config[:test][:stream] = nil
        Padrino::Logger.setup!
        assert_equal $stdout, Padrino.logger.log
      end

      should 'use StringIO as default for test' do
        assert_instance_of StringIO, Padrino.logger.log
      end

      should 'use a custom stream' do
        my_stream = StringIO.new
        Padrino::Logger::Config[:test][:stream] = my_stream
        Padrino::Logger.setup!
        assert_equal my_stream, Padrino.logger.log
      end
    end

    should 'log something' do
      setup_logger(:log_level => :error)
      @logger.error "You log this error?"
      assert_match(/You log this error?/, @log.string)
      @logger.debug "You don't log this error!"
      assert_no_match(/You don't log this error!/, @log.string)
      @logger << "Yep this can be logged"
      assert_match(/Yep this can be logged/, @log.string)
    end

    should 'respond to #write for Rack::CommonLogger' do
      setup_logger(:log_level => :error)
      @logger.error "Error message"
      assert_match /Error message/, @log.string
      @logger << "logged anyways"
      assert_match /logged anyways/, @log.string
      @logger.write "log via alias"
      assert_match /log via alias/, @log.string
    end

    should 'log an application' do
      mock_app do
        enable :logging
        get("/"){ "Foo" }
      end
      get "/"
      assert_equal "Foo", body
      assert_match /GET/, Padrino.logger.log.string
    end

    should 'log an application\'s status code' do
      mock_app do
        enable :logging
        get("/"){ "Foo" }
      end
      get "/"
      assert_match /\e\[1m200\e\[0m OK/, Padrino.logger.log.string
    end

    context "static asset logging" do
      should 'not log static assets by default' do
        mock_app do
          enable :logging
          get("/images/something.png"){ env["sinatra.static_file"] = '/public/images/something.png'; "Foo" }
        end
        get "/images/something.png"
        assert_equal "Foo", body
        assert_match "", Padrino.logger.log.string
      end

      should 'allow turning on static assets logging' do
        Padrino.logger.instance_eval{ @log_static = true }
        mock_app do
          enable :logging
          get("/images/something.png"){ env["sinatra.static_file"] = '/public/images/something.png'; "Foo" }
        end
        get "/images/something.png"
        assert_equal "Foo", body
        assert_match /GET/, Padrino.logger.log.string
        Padrino.logger.instance_eval{ @log_static = false }
      end
    end

    context "health-check requests logging" do
      def access_to_mock_app
        mock_app do
          enable :logging
          get("/"){ "Foo" }
        end
        get "/"
      end

      should 'output under debug level' do
        Padrino.logger.instance_eval{ @level = Padrino::Logger::Levels[:debug] }
        access_to_mock_app
        assert_match /\e\[36m  DEBUG\e\[0m/, Padrino.logger.log.string

        Padrino.logger.instance_eval{ @level = Padrino::Logger::Levels[:devel] }
        access_to_mock_app
        assert_match /\e\[36m  DEBUG\e\[0m/, Padrino.logger.log.string
      end
      should 'not output over debug level' do
        Padrino.logger.instance_eval{ @level = Padrino::Logger::Levels[:info] }
        access_to_mock_app
        assert_equal '', Padrino.logger.log.string

        Padrino.logger.instance_eval{ @level = Padrino::Logger::Levels[:error] }
        access_to_mock_app
        assert_equal '', Padrino.logger.log.string
      end
    end
  end
end

describe "alternate logger: Lumberjack" do
  def setup_logger
    @log = StringIO.new
    Padrino.logger = Lumberjack::Logger.new(@log, :level => :debug)
  end

  should "annotate the logger to support additional Padrino fancyness" do
    setup_logger
    Padrino.logger.debug("Debug message")
    assert_match(/Debug message/, @log.string)
  end

  should "colorize log output after colorize! is called" do
    setup_logger
    Padrino.logger.colorize!

    mock_app do
      enable :logging
      get("/"){ "Foo" }
    end
    get "/"

    assert_match /\e\[1m200\e\[0m OK/, @log.string
  end
end

describe "alternate logger: stdlib logger" do
  def setup_logger
    @log = StringIO.new
    Padrino.logger = Logger.new(@log)
  end

  should "annotate the logger to support additional Padrino fancyness" do
    setup_logger
    Padrino.logger.debug("Debug message")
    assert_match(/Debug message/, @log.string)
  end

  should "colorize log output after colorize! is called" do
    setup_logger
    Padrino.logger.colorize!

    mock_app do
      enable :logging
      get("/"){ "Foo" }
    end
    get "/"

    assert_match /\e\[1m200\e\[0m OK/, @log.string
  end
end

describe "options :colorize_logging" do
  def access_to_mock_app
    mock_app do
      enable :logging
      get("/"){ "Foo" }
    end
    get "/"
  end
  context 'default' do
    should 'use colorize logging' do
      Padrino::Logger.setup!

      access_to_mock_app
      assert_match /\e\[1m200\e\[0m OK/, Padrino.logger.log.string
    end
  end
  context 'set value is false' do
    should 'not use colorize logging' do
      Padrino::Logger::Config[:test][:colorize_logging] = false
      Padrino::Logger.setup!

      access_to_mock_app
      assert_match /200 OK/, Padrino.logger.log.string
    end
  end
end
