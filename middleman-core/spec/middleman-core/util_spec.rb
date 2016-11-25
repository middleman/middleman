require 'spec_helper'
require 'middleman-core'

describe Middleman::Util do

  describe "::path_match" do
    it "matches a literal string" do
      expect(Middleman::Util.path_match '/index.html', '/index.html').to be true
    end

    it "won't match a wrong string" do
      expect(Middleman::Util.path_match '/foo.html', '/index.html').to be false
    end

    it "won't match a partial string" do
      expect(Middleman::Util.path_match 'ind', '/index.html').to be false
    end

    it "works with a regex" do
      expect(Middleman::Util.path_match /\.html$/, '/index.html').to be true
      expect(Middleman::Util.path_match /\.js$/, '/index.html').to be false
    end

    it "works with a proc" do
      matcher = lambda {|p| p.length > 5 }

      expect(Middleman::Util.path_match matcher, '/index.html').to be true
      expect(Middleman::Util.path_match matcher, '/i').to be false
    end

    it "works with globs" do
      expect(Middleman::Util.path_match '/foo/*.html', '/foo/index.html').to be true
      expect(Middleman::Util.path_match '/foo/*.html', '/foo/index.js').to be false
      expect(Middleman::Util.path_match '/bar/*.html', '/foo/index.js').to be false

      expect(Middleman::Util.path_match '/foo/*', '/foo/bar/index.html').to be true
      expect(Middleman::Util.path_match '/foo/**/*', '/foo/bar/index.html').to be true
      expect(Middleman::Util.path_match '/foo/**', '/foo/bar/index.html').to be true
    end
  end

  describe "::binary?" do
    %w(plain.txt unicode.txt unicode).each do |file|
      it "recognizes #{file} as not binary" do
        expect(Middleman::Util.binary?(File.join(File.dirname(__FILE__), "binary_spec/#{file}"))).to be false
      end
    end

    %w(middleman.png middleman stars.svgz).each do |file|
      it "recognizes #{file} as binary" do
        expect(Middleman::Util.binary?(File.join(File.dirname(__FILE__), "binary_spec/#{file}"))).to be true
      end
    end
  end

  describe "::recursively_enhance" do
    it "returns Hashie extended Hash if given a hash" do
      input   = {test: "subject"}
      subject = Middleman::Util.recursively_enhance input

      expect( subject.test ).to eq "subject"
    end

    it "returns Array with strings, or IndifferentHash, true, false" do
      indifferent_hash = {test: "subject"}
      regular_hash     = {regular: "hash"}
      input   = [ indifferent_hash, regular_hash, true, false ]
      subject = Middleman::Util.recursively_enhance input

      expect( subject[1].regular ).to eq "hash"
      expect( subject[2] ).to eq true
      expect( subject[3] ).to eq false
    end
  end

  describe "::asset_url" do

    after(:each) do
      Given.cleanup!
    end

    context "when http_prefix is activated" do

      before(:each) do
        Given.fixture 'clean-dir-app'
        Given.file 'source/images/blank.gif', ''
        @mm = Middleman::Application.new do
          config[:http_prefix] = 'http_prefix'
        end
      end

      it "returns path with http_prefix pre-pended if resource is found" do
        expect( Middleman::Util.asset_url( @mm, 'blank.gif', 'images', http_prefix: 'http_prefix' ) ).to eq 'http_prefix/images/blank.gif'
      end

      it "returns path with http_prefix pre-pended if resource is not found" do
        expect( Middleman::Util.asset_url( @mm, 'missing.gif', 'images', http_prefix: 'http_prefix' ) ).to eq 'http_prefix/images/missing.gif'
      end
    end

    it "returns path relative to the provided current_resource" do
      Given.fixture 'clean-dir-app'
      Given.file 'source/a-path/index.html', ''
      Given.file 'source/a-path/images/blank.gif', ''
      @mm = Middleman::Application.new
      current_resource = @mm.sitemap.find_resource_by_path('a-path/index.html')
      expect( Middleman::Util.asset_url( @mm, 'images/blank.gif', 'images', current_resource: current_resource ) ).to eq '/a-path/images/blank.gif'
    end

    context "when relative is true" do

      before(:each) do
        Given.fixture 'relative-assets-app'
        @mm = Middleman::Application.new
      end

      it "returns path relative to the provided current_resource" do
        current_resource = instance_double("Middleman::Sitemap::Resource", destination_path: 'a-path/index.html', path: 'a-path/index.html')
        expect( Middleman::Util.asset_url( @mm, 'blank.gif', 'images', current_resource: current_resource,
                                                                       relative: true ) ).to eq '../images/blank.gif'
      end

      context "when the asset is stored in the same directory as current_resource" do
        before do
          Given.file 'source/a-path/index.html', ''
          Given.file 'source/a-path/blank.gif', ''
          @mm = Middleman::Application.new
        end

        it "returns path relative to the provided current_resource" do
          current_resource = @mm.sitemap.find_resource_by_path('a-path/index.html')
          expect( Middleman::Util.asset_url( @mm, 'blank.gif', 'images', current_resource: current_resource,
                                                                        relative: true) ).to eq 'blank.gif'
        end
      end

      it "raises error if not given a current_resource" do
        expect{
          Middleman::Util.asset_url( @mm, 'blank.gif', 'images', relative: true )
        }.to raise_error ArgumentError
      end
    end

    it "returns path if it is already a full path" do
      expect( Middleman::Util.asset_url( @mm, 'http://example.com' ) ).to eq 'http://example.com'
      expect( Middleman::Util.asset_url( @mm, 'data:example' ) ).to eq 'data:example'
    end

    it "returns a resource url if given a resource's destination path" do
      Given.fixture 'clean-dir-app' # includes directory indexes extension
      Given.file 'source/how/about/that.html', ''
      @mm = Middleman::Application.new

      expect( Middleman::Util.asset_url( @mm, '/how/about/that/index.html' ) ).to eq '/how/about/that/'
    end

    it "returns a resource url if given a resources path" do
      Given.fixture 'clean-dir-app' # includes directory indexes extension
      Given.file 'source/how/about/that.html', ''
      @mm = Middleman::Application.new

      expect( Middleman::Util.asset_url( @mm, '/how/about/that.html' ) ).to eq '/how/about/that/'
    end

    it "returns a resource url when asset_hash is on" do
      Given.fixture 'asset-hash-app'
      @mm = Middleman::Application.new

      expect( Middleman::Util.asset_url( @mm, '100px.png', 'images') ).to match %r|/images/100px-[a-f0-9]+.png|
    end

  end

  describe "::find_related_files" do
    after(:each) do
      Given.cleanup!
    end

    before(:each) do
      Given.fixture 'related-files-app'
      @mm = Middleman::Application.new
    end

    def source_file(path)
      Pathname(File.expand_path("source/#{path}"))
    end

    it "Finds partials possibly related to ERb files" do
      related = Middleman::Util.find_related_files(@mm, [source_file('partials/_test.erb')]).map { |f| f[:full_path].to_s }
      expect(related).to include File.expand_path("source/index.html.erb")

      related = Middleman::Util.find_related_files(@mm, [source_file('partials/_test2.haml')]).map { |f| f[:full_path].to_s }
      expect(related).to include File.expand_path("source/index.html.erb")
    end

    it "Finds partials possible related to Scss files" do
      related = Middleman::Util.find_related_files(@mm, [source_file('stylesheets/_include4.scss')]).map { |f| f[:full_path].to_s }
      expect(related).to include File.expand_path("source/stylesheets/site.css.scss")
      expect(related).to include File.expand_path("source/stylesheets/include2.css.scss")

      related = Middleman::Util.find_related_files(@mm, [source_file('stylesheets/include2.css.scss')]).map { |f| f[:full_path].to_s }
      expect(related).to include File.expand_path("source/stylesheets/site.css.scss")
      expect(related).not_to include File.expand_path("source/stylesheets/include2.css.scss")

      related = Middleman::Util.find_related_files(@mm, [source_file('stylesheets/include1.css')]).map { |f| f[:full_path].to_s }
      expect(related).to include File.expand_path("source/stylesheets/site.css.scss")
      expect(related).to include File.expand_path("source/stylesheets/include2.css.scss")

      related = Middleman::Util.find_related_files(@mm, [source_file('stylesheets/_include3.sass')]).map { |f| f[:full_path].to_s }
      expect(related).to include File.expand_path("source/stylesheets/site.css.scss")
      expect(related).to include File.expand_path("source/stylesheets/include2.css.scss")
    end
  end

  describe "::step_through_extensions" do
    it "returns the base name after templating engine extensions are removed" do
      result = Middleman::Util.step_through_extensions('my_file.html.haml.erb')
      expect(result).to eq 'my_file.html'
    end

    it "does not loop infinitely when file name is a possible templating engine" do
      expect do
        Timeout::timeout(3.0) do
          result = Middleman::Util.step_through_extensions("markdown.scss")
          expect(result).to eq "markdown"
        end
      end.not_to raise_error
    end
  end
end
