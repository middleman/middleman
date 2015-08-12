require 'spec_helper'
require 'middleman-core/util'

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

end