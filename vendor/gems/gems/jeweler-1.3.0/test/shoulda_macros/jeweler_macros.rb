class Test::Unit::TestCase
  class << self
    def should_have_major_version(version)
      should "have major version of #{version}" do 
        assert_equal version, @jeweler.major_version
      end
    end
    
    def should_have_minor_version(version)
      should "have minor version of #{version}" do
        assert_equal version, @jeweler.minor_version
      end
    end
    
    def should_have_patch_version(version)
      should "have patch version of #{version}" do
        assert_equal version, @jeweler.patch_version
      end
    end
    
    def should_be_version(version)
      should "be version #{version}" do
        assert_equal version, @jeweler.version
      end
    end
    
    def should_bump_version(major, minor, patch)
      version = "#{major}.#{minor}.#{patch}"
      should_have_major_version major
      should_have_minor_version minor
      should_have_patch_version patch
      should_be_version version
    end
  end
end
