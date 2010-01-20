require "test_helper"

class PathnameTest < Test::Unit::TestCase
  def setup
    @environment = environment_for_fixtures
  end
  
  def test_absolute_location_is_automatically_expanded
    expanded_location = File.expand_path(File.join(FIXTURES_PATH, "foo"))
    assert_absolute_location expanded_location, pathname("foo")
    assert_absolute_location expanded_location, pathname("./foo")
    assert_absolute_location expanded_location, pathname("./foo/../foo")
  end
  
  def test_find_should_return_a_pathname_for_the_location_relative_to_the_absolute_location_of_the_pathname
    assert_absolute_location_ends_with "src/foo/bar.js", pathname("src/foo").find("bar.js")
  end
  
  def test_find_should_return_nil_when_the_location_relative_to_the_absolute_location_of_the_pathname_is_not_a_file_or_does_not_exist
    assert_nil pathname("src/foo").find("nonexistent.js")
  end
  
  def test_parent_pathname_should_return_a_pathname_for_the_parent_directory
    assert_absolute_location_ends_with "src", pathname("src/foo").parent_pathname
    assert_absolute_location_ends_with "foo", pathname("src/foo/foo.js").parent_pathname
  end
  
  def test_source_file_should_return_a_source_file_for_the_pathname
    source_file = pathname("src/foo.js").source_file
    assert_kind_of Sprockets::SourceFile, source_file
    assert_equal pathname("src/foo.js"), source_file.pathname
  end

  def test_equality_of_pathnames
    assert_equal pathname("src/foo.js"), pathname("src/foo.js")
    assert_equal pathname("src/foo.js"), pathname("src/foo/../foo.js")
    assert_not_equal pathname("src/foo.js"), pathname("src/foo/foo.js")
  end
  
  def test_to_s_should_return_absolute_location
    assert_equal pathname("src/foo.js").to_s, pathname("src/foo.js").absolute_location
  end
end
