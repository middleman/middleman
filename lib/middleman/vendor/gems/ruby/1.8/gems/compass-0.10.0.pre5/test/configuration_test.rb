require 'test_helper'
require 'compass'
require 'stringio'

class ConfigurationTest < Test::Unit::TestCase
  include Compass::IoHelper

  def setup
    Compass.reset_configuration!
  end

  def test_parse_and_serialize
    contents = StringIO.new(<<-CONFIG)
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

    Compass.add_configuration(contents, "test_parse")

    assert_equal 'sass', Compass.configuration.sass_dir
    assert_equal 'css', Compass.configuration.css_dir
    assert_equal 'img', Compass.configuration.images_dir
    assert_equal 'js', Compass.configuration.javascripts_dir

    expected_lines = contents.string.split("\n").map{|l|l.strip}
    actual_lines = Compass.configuration.serialize.split("\n").map{|l|l.strip}
    assert_equal expected_lines, actual_lines
  end

  def test_serialization_warns_with_asset_host_set
    contents = StringIO.new(<<-CONFIG)
      asset_host do |path|
        "http://example.com"
      end
    CONFIG

    Compass.add_configuration(contents, "test_serialization_warns_with_asset_host_set")

    warning = capture_warning do
      Compass.configuration.serialize
    end
    assert_equal "WARNING: asset_host is code and cannot be written to a file. You'll need to copy it yourself.\n", warning
  end

  def test_serialization_warns_with_asset_cache_buster_set
    contents = StringIO.new(<<-CONFIG)
      asset_cache_buster do |path|
        "http://example.com"
      end
    CONFIG

    Compass.add_configuration(contents, "test_serialization_warns_with_asset_cache_buster_set")

    warning = capture_warning do
      Compass.configuration.serialize
    end
    assert_equal "WARNING: asset_cache_buster is code and cannot be written to a file. You'll need to copy it yourself.\n", warning
  end

  def test_additional_import_paths
    contents = StringIO.new(<<-CONFIG)
      http_path = "/"
      project_path = "/home/chris/my_compass_project"
      css_dir = "css"
      additional_import_paths = ["../foo"]
      add_import_path "/path/to/my/framework"
    CONFIG

    Compass.add_configuration(contents, "test_additional_import_paths")

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
    assert_equal expected_serialization.split("\n"), Compass.configuration.serialize.split("\n")
  end

    def test_sass_options
      contents = StringIO.new(<<-CONFIG)
        sass_options = {:foo => 'bar'}
      CONFIG

      Compass.add_configuration(contents, "test_sass_options")

      assert_equal 'bar', Compass.configuration.to_sass_engine_options[:foo]
      assert_equal 'bar', Compass.configuration.to_sass_plugin_options[:foo]

      expected_serialization = <<EXPECTED
# Require any additional compass plugins here.
# Set this to the root of your project when deployed:
http_path = "/"
# To enable relative paths to assets via compass helper functions. Uncomment:
# relative_assets = true
sass_options = {:foo=>"bar"}
EXPECTED

      assert_equal expected_serialization, Compass.configuration.serialize
    end

  def test_strip_trailing_directory_separators
    contents = StringIO.new(<<-CONFIG)
      css_dir = "css/"
      sass_dir = "sass/"
      images_dir = "images/"
      javascripts_dir = "js/"
      fonts_dir = "fonts/"
      extensions_dir = "extensions/"
      css_path = "css/"
      sass_path = "sass/"
      images_path = "images/"
      javascripts_path = "js/"
      fonts_path = "fonts/"
      extensions_path = "extensions/"
    CONFIG

    Compass.add_configuration(contents, "test_strip_trailing_directory_separators")

    assert_equal "css", Compass.configuration.css_dir
    assert_equal "sass", Compass.configuration.sass_dir
    assert_equal "images", Compass.configuration.images_dir
    assert_equal "js", Compass.configuration.javascripts_dir
    assert_equal "fonts", Compass.configuration.fonts_dir
    assert_equal "extensions", Compass.configuration.extensions_dir
  end
end
