require 'test_helper'

class TestApplication < Test::Unit::TestCase
  def run_application(*arguments)
    original_stdout = $stdout
    original_stderr = $stderr

    fake_stdout = StringIO.new
    fake_stderr = StringIO.new

    $stdout = fake_stdout
    $stderr = fake_stderr

    result = nil
    begin
      result = Jeweler::Generator::Application.run!(*arguments)
    ensure
      $stdout = original_stdout
      $stderr = original_stderr
    end

    @stdout = fake_stdout.string
    @stderr = fake_stderr.string

    result
  end

  def stub_options(options)
    stub(options).opts { 'Usage:' }

    stub(Jeweler::Generator::Options).new { options }

    options
  end

  def self.should_exit_with_code(code)
    should "exit with code #{code}" do
      assert_equal code, @result
    end
  end

  context "when options indicate help usage" do
    setup do
      stub_options :show_help => true
      stub(Jeweler::Generator).new { raise "Shouldn't have made this far"}

      assert_nothing_raised do
        @result = run_application("-h")
      end
    end

    should_exit_with_code 1

    should 'should puts option usage' do
      assert_match 'Usage:', @stderr
    end

    should 'not display anything on stdout' do
      assert_equal '', @stdout.squeeze.strip
    end
  end

  context "when options indicate an invalid argument" do
    setup do
      stub_options :invalid_argument => '--invalid-argument'
      stub(Jeweler::Generator).new { raise "Shouldn't have made this far"}

      assert_nothing_raised do
        @result = run_application("--invalid-argument")
      end
    end

    should_exit_with_code 1

    should 'display invalid argument' do
      assert_match '--invalid-argument', @stderr
    end

    should 'display usage on stderr' do
      assert_match 'Usage:', @stderr
    end

    should 'not display anything on stdout' do
      assert_equal '', @stdout.squeeze.strip
    end

  end

  context "when options are good" do
    setup do
      @options   = stub_options :project_name => 'zomg'
      @generator = "generator"
      stub(@generator).run
      stub(Jeweler::Generator).new { @generator }

      assert_nothing_raised do
        @result = run_application("zomg")
      end
    end

    should_exit_with_code 0

    should "create generator with options" do
      assert_received(Jeweler::Generator) {|subject| subject.new(@options) }
    end

    should "run generator" do
      assert_received(@generator) {|subject| subject.run }
    end
  end

end
