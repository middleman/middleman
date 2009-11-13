require  File.dirname(__FILE__)+'/test_helper'
require 'fileutils'
require 'compass'

class CompassTest < Test::Unit::TestCase
  include Compass::TestCaseHelper
  def setup
    Compass.configuration.reset!
  end

  def teardown
    teardown_fixtures :blueprint, :yui, :empty, :compass, :image_urls
  end

  def teardown_fixtures(*project_names)
    project_names.each do |project_name|
      FileUtils.rm_rf tempfile_path(project_name)
    end
  end

  def test_empty_project
    # With no sass files, we should have no css files.
    within_project(:empty) do |proj|
      return unless proj.css_path && File.exists?(proj.css_path)
      Dir.new(proj.css_path).each do |f|
        fail "This file should not have been generated: #{f}" unless f == "." || f == ".."
      end
    end
  end

  def test_blueprint
    within_project(:blueprint) do |proj|
      each_css_file(proj.css_path) do |css_file|
        assert_no_errors css_file, :blueprint
      end
      assert_renders_correctly :typography
    end
  end

  def test_yui
    within_project('yui') do |proj|
      each_css_file(proj.css_path) do |css_file|
        assert_no_errors css_file, 'yui'
      end
      assert_renders_correctly :mixins
    end
  end

  def test_compass
    within_project('compass') do |proj|
      each_css_file(proj.css_path) do |css_file|
        assert_no_errors css_file, 'compass'
      end
      assert_renders_correctly :reset, :layout, :utilities
    end
  end

  def test_image_urls
    within_project('image_urls') do |proj|
      each_css_file(proj.css_path) do |css_file|
        assert_no_errors css_file, 'image_urls'
      end
      assert_renders_correctly :screen
    end
  end

private
  def assert_no_errors(css_file, project_name)
    file = css_file[(tempfile_path(project_name).size+1)..-1]
    msg = "Syntax Error found in #{file}. Results saved into #{save_path(project_name)}/#{file}"
    assert_equal 0, open(css_file).readlines.grep(/Sass::SyntaxError/).size, msg
  end

  def assert_renders_correctly(*arguments)
    options = arguments.last.is_a?(Hash) ? arguments.pop : {}
    for name in arguments
      actual_result_file = "#{tempfile_path(@current_project)}/#{name}.css"
      expected_result_file = "#{result_path(@current_project)}/#{name}.css"
      actual_lines = File.read(actual_result_file).split("\n")
      expected_lines = File.read(expected_result_file).split("\n")
      expected_lines.zip(actual_lines).each_with_index do |pair, line|
        message = "template: #{name}\nline:     #{line + 1}"
        assert_equal(pair.first, pair.last, message)
      end
      if expected_lines.size < actual_lines.size
        assert(false, "#{actual_lines.size - expected_lines.size} Trailing lines found in #{actual_result_file}.css: #{actual_lines[expected_lines.size..-1].join('\n')}")
      end
    end
  end

  def within_project(project_name)
    @current_project = project_name
    Compass.configuration.parse(configuration_file(project_name)) if File.exists?(configuration_file(project_name))
    Compass.configuration.project_path = project_path(project_name)
    args = Compass.configuration.to_compiler_arguments(:logger => Compass::NullLogger.new)
    if Compass.configuration.sass_path && File.exists?(Compass.configuration.sass_path)
      compiler = Compass::Compiler.new *args
      compiler.run
    end
    yield Compass.configuration
  rescue
    save_output(project_name)    
    raise
  end
  
  def each_css_file(dir)
    Dir.glob("#{dir}/**/*.css").each do |css_file|
      yield css_file
    end
  end

  def save_output(dir)
    FileUtils.rm_rf(save_path(dir))
    FileUtils.cp_r(tempfile_path(dir), save_path(dir)) if File.exists?(tempfile_path(dir))
  end

  def project_path(project_name)
    absolutize("fixtures/stylesheets/#{project_name}")
  end

  def configuration_file(project_name)
    File.join(project_path(project_name), "config.rb")
  end

  def tempfile_path(project_name)
    File.join(project_path(project_name), "tmp")
  end
  
  def template_path(project_name)
    File.join(project_path(project_name), "sass")
  end
  
  def result_path(project_name)
    File.join(project_path(project_name), "css")
  end
  
  def save_path(project_name)
    File.join(project_path(project_name), "saved")
  end

end