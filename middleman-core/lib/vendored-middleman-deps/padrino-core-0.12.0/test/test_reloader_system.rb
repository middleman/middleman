require File.expand_path(File.dirname(__FILE__) + '/helper')
require File.expand_path(File.dirname(__FILE__) + '/fixtures/apps/kiq')
require File.expand_path(File.dirname(__FILE__) + '/fixtures/apps/system')
require File.expand_path(File.dirname(__FILE__) + '/fixtures/apps/static')

describe "SystemReloader" do
  context 'for wierd and difficult reload events' do
    should 'reload system features if they were required only in helper' do
      @app = SystemDemo
      @app.reload!
      get '/'
      assert_equal 'Resolv', body
    end

    should 'reload children on parent change' do
      @app = SystemDemo
      assert_equal Child.new.family, 'Danes'
      parent_file = File.expand_path(File.dirname(__FILE__) + '/fixtures/apps/models/parent.rb')
      new_class = <<-DOC
        class Parent
          def family
            'Dancy'
          end
          def shmamily
            'Shmancy'
          end
        end
      DOC
      begin
        backup = File.read(parent_file)
        Padrino::Reloader.reload!
        assert_equal 'Danes', Parent.new.family
        assert_equal 'Danes', Child.new.family
        File.open(parent_file, "w") { |f| f.write(new_class) }
        Padrino::Reloader.reload!
        assert_equal 'Dancy', Parent.new.family
        assert_equal 'Shmancy', Parent.new.shmamily
        assert_equal 'Dancy', Child.new.family
        assert_equal 'Shmancy', Child.new.shmamily
      ensure
        File.open(parent_file, "w") { |f| f.write(backup) }
      end
    end

    should 'tamper with LOAD_PATH' do
      SystemDemo.load_paths.each do |lib_dir|
        assert_includes $LOAD_PATH, lib_dir
      end
      Padrino.send(:load_paths_was).each do |lib_dir|
        assert_includes $LOAD_PATH, lib_dir
      end
    end

    should 'not fail horribly on reload event with non-padrino apps' do
      Padrino.mount("kiq").to("/")
      Padrino.reload!
    end

    should 'not reload apps with disabled reload' do
      Padrino.mount(StaticDemo).to("/")
      Padrino.reload!
    end
  end
end
