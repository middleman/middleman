require 'middleman-core/util'

describe "Middleman::Util#binary?" do
  %w(plain.txt unicode.txt unicode).each do |file|
    it "recognizes #{file} as not binary" do
      Middleman::Util.binary?(File.join(File.dirname(__FILE__), "binary_spec/#{file}")).should be_false
    end
  end

  %w(middleman.png middleman stars.svgz).each do |file|
    it "recognizes #{file} as binary" do
      Middleman::Util.binary?(File.join(File.dirname(__FILE__), "binary_spec/#{file}")).should be_true
    end
  end
end
