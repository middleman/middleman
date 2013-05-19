require File.expand_path('../../../load_paths', __FILE__)
require File.join(File.dirname(__FILE__), '..', '..', 'padrino-core', 'test', 'mini_shoulda')
require 'rack/test'
require 'webrat'
require 'padrino-helpers'
require 'active_support/time'

class MiniTest::Spec
  include Padrino::Helpers::OutputHelpers
  include Padrino::Helpers::TagHelpers
  include Padrino::Helpers::AssetTagHelpers
  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers

  Webrat.configure do |config|
    config.mode = :rack
  end

  def stop_time_for_test
    time = Time.now
    Time.stubs(:now).returns(time)
    return time
  end

  # assert_has_tag(:h1, :content => "yellow") { "<h1>yellow</h1>" }
  # In this case, block is the html to evaluate
  def assert_has_tag(name, attributes = {}, &block)
    html = block && block.call
    matcher = HaveSelector.new(name, attributes)
    raise "Please specify a block!" if html.blank?
    assert matcher.matches?(html), matcher.failure_message
  end

  # assert_has_no_tag, tag(:h1, :content => "yellow") { "<h1>green</h1>" }
  # In this case, block is the html to evaluate
  def assert_has_no_tag(name, attributes = {}, &block)
    html = block && block.call
    attributes.merge!(:count => 0)
    matcher = HaveSelector.new(name, attributes)
    raise "Please specify a block!" if html.blank?
    assert matcher.matches?(html), matcher.failure_message
  end

  # Asserts that a file matches the pattern
  def assert_match_in_file(pattern, file)
    assert File.exist?(file), "File '#{file}' does not exist!"
    assert_match pattern, File.read(file)
  end

  # mock_model("Business", :new_record? => true) => <Business>
  def mock_model(klazz, options={})
    options.reverse_merge!(:class => klazz, :new_record? => false, :id => 20, :errors => {})
    record = stub(options)
    record.stubs(:to_ary => [record])
    record
  end
end

module Webrat
  module Logging
    def logger # @private
      @logger = nil
    end
  end
end
