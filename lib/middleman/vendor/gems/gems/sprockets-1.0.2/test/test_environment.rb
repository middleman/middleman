require "test_helper"

class EnvironmentTest < Test::Unit::TestCase
  def test_load_path_locations_become_pathnames_for_absolute_locations_from_the_root
    environment = Sprockets::Environment.new("/root", ["/a", "b"])
    assert_load_path_equals ["/a", "/root/b", "/root"], environment
  end
  
  def test_pathname_from_for_location_with_leading_slash_should_return_a_pathname_with_the_location_unchanged
    environment = Sprockets::Environment.new("/root")
    assert_absolute_location "/a", environment.pathname_from("/a")
  end
  
  def test_pathname_from_for_relative_location_should_return_a_pathname_for_the_expanded_absolute_location_from_root
    environment = Sprockets::Environment.new("/root")
    assert_absolute_location "/root/a", environment.pathname_from("a")
    assert_absolute_location "/root/a", environment.pathname_from("./a")
    assert_absolute_location "/a", environment.pathname_from("../a")
  end
  
  def test_register_load_location_should_unshift_the_location_onto_the_load_path
    environment = Sprockets::Environment.new("/root")
    environment.register_load_location("a")
    assert_load_path_equals ["/root/a", "/root"], environment
    environment.register_load_location("b")
    assert_load_path_equals ["/root/b", "/root/a", "/root"], environment
  end
  
  def test_register_load_location_should_remove_already_existing_locations_before_unshifting
    environment = Sprockets::Environment.new("/root")
    environment.register_load_location("a")
    environment.register_load_location("b")
    assert_load_path_equals ["/root/b", "/root/a", "/root"], environment
    environment.register_load_location("a")
    assert_load_path_equals ["/root/a", "/root/b", "/root"], environment
  end
  
  def test_find_should_return_the_first_matching_pathname_in_the_load_path
    environment = environment_for_fixtures
    first_pathname = environment.find("foo.js")
    assert_absolute_location_ends_with "src/foo.js", first_pathname
    
    environment.register_load_location(File.join(FIXTURES_PATH, "src", "foo"))
    second_pathname = environment.find("foo.js")
    assert_not_equal first_pathname, second_pathname
    assert_absolute_location_ends_with "foo/foo.js", second_pathname
  end
  
  def test_find_should_return_nil_when_no_matching_source_file_is_found
    environment = environment_for_fixtures
    assert_nil environment.find("nonexistent.js")
  end
  
  def test_constants_should_return_a_hash_of_all_constants_defined_in_the_load_path
    constants = environment_for_fixtures.constants
    assert_kind_of Hash, constants
    assert_equal %w(HELLO ONE TWO VERSION), constants.keys.sort
  end
  
  protected
    def assert_load_path_equals(load_path_absolute_locations, environment)
      assert load_path_absolute_locations.zip(environment.load_path).map { |location, pathname| File.expand_path(location) == pathname.absolute_location }.all?
    end
end
