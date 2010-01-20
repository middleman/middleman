require "test_helper"

class SecretaryTest < Test::Unit::TestCase
  def test_load_locations_are_not_expanded_when_expand_paths_is_false
    secretary = Sprockets::Secretary.new(:root => FIXTURES_PATH)
    secretary.add_load_location("src/**/", :expand_paths => false)
    
    assert_equal [File.join(FIXTURES_PATH, "src/**"), FIXTURES_PATH], 
                 secretary.environment.load_path.map { |pathname| pathname.absolute_location }
  end
  
  def test_load_locations_are_expanded_when_expand_paths_is_true
    secretary = Sprockets::Secretary.new(:root => FIXTURES_PATH)
    secretary.add_load_location("src/**/", :expand_paths => true)
    
    assert_equal [File.join(FIXTURES_PATH, "src", "foo"), File.join(FIXTURES_PATH, "src"), FIXTURES_PATH],
                 secretary.environment.load_path.map { |pathname| pathname.absolute_location }
  end
  
  def test_source_files_are_not_expanded_when_expand_paths_is_false
    secretary = Sprockets::Secretary.new(:root => FIXTURES_PATH)
    assert_raises(Sprockets::LoadError) do
      secretary.add_source_file("src/f*.js", :expand_paths => false)
    end
  end
  
  def test_source_files_are_expanded_when_expand_paths_is_true
    secretary = Sprockets::Secretary.new(:root => FIXTURES_PATH)
    secretary.add_source_file("src/f*.js", :expand_paths => true)
    
    assert_equal [File.join(FIXTURES_PATH, "src", "foo.js")],
                 secretary.preprocessor.source_files.map { |source_file| source_file.pathname.absolute_location }
  end
  
  def test_install_assets_into_empty_directory
    with_temporary_directory do |temp|
      secretary = Sprockets::Secretary.new(:root => FIXTURES_PATH, :asset_root => temp)
      secretary.add_source_file("src/script_with_assets.js")

      assert_equal [], Dir[File.join(temp, "**", "*")]
      secretary.install_assets
      assert_equal paths_relative_to(temp, 
        "images", "images/script_with_assets", "images/script_with_assets/one.png", 
        "images/script_with_assets/two.png", "stylesheets", "stylesheets/script_with_assets.css"),
        Dir[File.join(temp, "**", "*")].sort
    end
  end
  
  def test_install_assets_into_nonexistent_directory
    with_temporary_directory do |temp|
      temp = File.join(temp, "assets")
      secretary = Sprockets::Secretary.new(:root => FIXTURES_PATH, :asset_root => temp)
      secretary.add_source_file("src/script_with_assets.js")

      assert_equal [], Dir[File.join(temp, "**", "*")]
      secretary.install_assets
      assert_equal paths_relative_to(temp, 
        "images", "images/script_with_assets", "images/script_with_assets/one.png", 
        "images/script_with_assets/two.png", "stylesheets", "stylesheets/script_with_assets.css"),
        Dir[File.join(temp, "**", "*")].sort
    end
  end
  
  def test_install_assets_into_subdirectories_that_already_exist
    with_temporary_directory do |temp|
      secretary = Sprockets::Secretary.new(:root => FIXTURES_PATH, :asset_root => temp)
      secretary.add_source_file("src/script_with_assets.js")

      FileUtils.mkdir_p(File.join(temp, "images", "script_with_assets"))
      assert_equal paths_relative_to(temp, "images", "images/script_with_assets"), Dir[File.join(temp, "**", "*")]
      secretary.install_assets
      assert_equal paths_relative_to(temp, 
        "images", "images/script_with_assets", "images/script_with_assets/one.png", 
        "images/script_with_assets/two.png", "stylesheets", "stylesheets/script_with_assets.css"),
        Dir[File.join(temp, "**", "*")].sort
    end
  end
  
  protected
    def paths_relative_to(root, *paths)
      paths.map { |path| File.join(root, path) }
    end
end
