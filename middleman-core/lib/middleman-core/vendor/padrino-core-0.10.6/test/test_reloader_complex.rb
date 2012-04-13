require File.expand_path(File.dirname(__FILE__) + '/helper')
require File.expand_path(File.dirname(__FILE__) + '/fixtures/apps/complex')

describe "ComplexReloader" do

  context 'for complex reload functionality' do
    setup do
      Padrino.clear!
      Padrino.mount("complex_1_demo").to("/complex_1_demo")
      Padrino.mount("complex_2_demo").to("/complex_2_demo")
    end

    should 'correctly instantiate Complex(1-2)Demo fixture' do
      assert_equal ["/complex_1_demo", "/complex_2_demo"], Padrino.mounted_apps.map(&:uri_root)
      assert_equal ["complex_1_demo", "complex_2_demo"], Padrino.mounted_apps.map(&:name)
      assert Complex1Demo.reload?
      assert Complex2Demo.reload?
      assert_match %r{fixtures/apps/complex.rb}, Complex1Demo.app_file
      assert_match %r{fixtures/apps/complex.rb}, Complex2Demo.app_file
    end

    should 'correctly reload Complex(1-2)Demo fixture' do
      assert_match %r{fixtures/apps/complex.rb}, Complex1Demo.app_file
      @app = Padrino.application

      get "/"
      assert_equal 404, status

      get "/complex_1_demo"
      assert_equal "Given random #{LibDemo.give_me_a_random}", body

      get "/complex_2_demo"
      assert_equal 200, status

      get "/complex_1_demo/old"
      assert_equal 200, status

      get "/complex_2_demo/old"
      assert_equal 200, status

      get "/complex_2_demo/var/destroy"
      assert_equal '{}', body

      new_phrase = "The magick number is: #{rand(2**255)}!"
      buffer     = File.read(Complex1Demo.app_file)
      new_buffer = buffer.gsub(/The magick number is: \d+!/, new_phrase)
      new_buffer.gsub!(/get\(:destroy\)/, 'get(:destroy, :with => :id)')
      begin
        File.open(Complex1Demo.app_file, "w") { |f| f.write(new_buffer) }
        sleep 1.2 # We need at least a cooldown of 1 sec.
        get "/complex_2_demo"
        assert_equal new_phrase, body

        # Re-Check that we didn't forget any route
        get "/complex_1_demo"
        assert_equal "Given random #{LibDemo.give_me_a_random}", body

        get "/complex_2_demo"
        assert_equal 200, status

        get "/complex_1_demo/old"
        assert_equal 200, status

        get "/complex_2_demo/old"
        assert_equal 200, status

        get "/complex_2_demo/var/destroy/variable"
        assert_equal '{:id=>"variable"}', body
      ensure
        # Now we need to prevent to commit a new changed file so we revert it
        File.open(Complex1Demo.app_file, "w") { |f| f.write(buffer) }
      end
    end
  end
end
