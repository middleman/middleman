require  File.dirname(__FILE__)+'/test_helper'
require 'compass'

class ConfigurationTest < Test::Unit::TestCase

  def setup
    Compass.configuration.reset!
  end

  def test_parse_and_serialize
    contents = <<-CONFIG
      require 'compass'
      # Require any additional compass plugins here.

      project_type = :stand_alone
      # Set this to the root of your project when deployed:
      http_path = "/"
      css_dir = "css"
      sass_dir = "sass"
      images_dir = "img"
      javascripts_dir = "js"
      output_style = :nested
      # To enable relative paths to assets via compass helper functions. Uncomment:
      # relative_assets = true
    CONFIG

    Compass.configuration.parse_string(contents, "test_parse")

    assert_equal 'sass', Compass.configuration.sass_dir
    assert_equal 'css', Compass.configuration.css_dir
    assert_equal 'img', Compass.configuration.images_dir
    assert_equal 'js', Compass.configuration.javascripts_dir

    expected_lines = contents.split("\n").map{|l|l.strip}
    actual_lines = Compass.configuration.serialize.split("\n").map{|l|l.strip}
    assert_equal expected_lines, actual_lines
  end

  def test_serialization_fails_with_asset_host_set
    contents = <<-CONFIG
      asset_host do |path|
        "http://example.com"
      end
    CONFIG

    Compass.configuration.parse_string(contents, "test_serialization_fails_with_asset_host_set")

    assert_raise Compass::Error do
      Compass.configuration.serialize
    end
  end

  def test_serialization_fails_with_asset_cache_buster_set
    contents = <<-CONFIG
      asset_cache_buster do |path|
        "http://example.com"
      end
    CONFIG

    Compass.configuration.parse_string(contents, "test_serialization_fails_with_asset_cache_buster_set")

    assert_raise Compass::Error do
      Compass.configuration.serialize
    end
  end

  def test_additional_import_paths
    contents = <<-CONFIG
      http_path = "/"
      project_path = "/home/chris/my_compass_project"
      css_dir = "css"
      additional_import_paths = ["../foo"]
      add_import_path "/path/to/my/framework"
    CONFIG

    Compass.configuration.parse_string(contents, "test_additional_import_paths")

    assert Compass.configuration.to_sass_engine_options[:load_paths].include?("/home/chris/my_compass_project/../foo")
    assert Compass.configuration.to_sass_engine_options[:load_paths].include?("/path/to/my/framework"), Compass.configuration.to_sass_engine_options[:load_paths].inspect
    assert_equal "/home/chris/my_compass_project/css/framework", Compass.configuration.to_sass_plugin_options[:template_location]["/path/to/my/framework"]
    assert_equal "/home/chris/my_compass_project/css/foo", Compass.configuration.to_sass_plugin_options[:template_location]["/home/chris/my_compass_project/../foo"]

    expected_serialization = <<EXPECTED
# Require any additional compass plugins here.
project_path = "/home/chris/my_compass_project"
# Set this to the root of your project when deployed:
http_path = "/"
css_dir = "css"
# To enable relative paths to assets via compass helper functions. Uncomment:
# relative_assets = true
additional_import_paths = ["../foo", "/path/to/my/framework"]
EXPECTED
    assert_equal "/", Compass.configuration.http_path
    assert_equal expected_serialization, Compass.configuration.serialize
  end

    def test_sass_options
      contents = <<-CONFIG
        sass_options = {:foo => 'bar'}
      CONFIG

      Compass.configuration.parse_string(contents, "test_sass_options")

      assert_equal 'bar', Compass.configuration.to_sass_engine_options[:foo]
      assert_equal 'bar', Compass.configuration.to_sass_plugin_options[:foo]

      expected_serialization = <<EXPECTED
# Require any additional compass plugins here.
# Set this to the root of your project when deployed:
# To enable relative paths to assets via compass helper functions. Uncomment:
# relative_assets = true
sass_options = {:foo=>"bar"}
EXPECTED

      assert_equal expected_serialization, Compass.configuration.serialize
    end

end