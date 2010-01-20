require "spec_helper"

describe Rack::Test::Session do

  def test_file_path
    File.dirname(__FILE__) + "/../../fixtures/foo.txt"
  end

  def uploaded_file
    Rack::Test::UploadedFile.new(test_file_path)
  end

  context "uploading a file" do
    it "sends the multipart/form-data content type" do
      post "/", "photo" => uploaded_file
      last_request.env["CONTENT_TYPE"].should include("multipart/form-data;")
    end

    it "sends regular params" do
      post "/", "photo" => uploaded_file, "foo" => "bar"
      last_request.POST["foo"].should == "bar"
    end

    it "sends nested params" do
      post "/", "photo" => uploaded_file, "foo" => {"bar" => "baz"}
      last_request.POST["foo"]["bar"].should == "baz"
    end

    it "sends multiple nested params" do
      post "/", "photo" => uploaded_file, "foo" => {"bar" => {"baz" => "bop"}}
      last_request.POST["foo"]["bar"]["baz"].should == "bop"
    end

    it "sends params with arrays" do
      pending "FIXME: should work the same with and without multipart" do
        post "/", "photo" => uploaded_file, "foo" => ["1", "2"]
        last_request.POST["foo"].should == ["1", "2"]
      end
    end

    it "sends params with encoding sensitive values" do
      post "/", "photo" => uploaded_file, "foo" => "bar? baz"
      last_request.POST["foo"].should == "bar? baz"
    end

    it "sends params with parens in names" do
      post "/", "photo" => uploaded_file, "foo(1i)" => "bar"
      last_request.POST["foo(1i)"].should == "bar"
    end

    it "sends params with encoding sensitive names" do
      post "/", "photo" => uploaded_file, "foo bar" => "baz"
      last_request.POST["foo bar"].should == "baz"
    end

    it "sends files with the filename" do
      post "/", "photo" => uploaded_file
      last_request.POST["photo"][:filename].should == "foo.txt"
    end

    it "sends files with the text/plain MIME type by default" do
      post "/", "photo" => uploaded_file
      last_request.POST["photo"][:type].should == "text/plain"
    end

    it "sends files with the right name" do
      post "/", "photo" => uploaded_file
      last_request.POST["photo"][:name].should == "photo"
    end

    it "allows overriding the content type" do
      post "/", "photo" => Rack::Test::UploadedFile.new(test_file_path, "image/jpeg")
      last_request.POST["photo"][:type].should == "image/jpeg"
    end

    it "sends files with a Content-Length in the header" do
      post "/", "photo" => uploaded_file
      last_request.POST["photo"][:head].should include("Content-Length: 4")
    end

    it "sends files as Tempfiles" do
      post "/", "photo" => uploaded_file
      last_request.POST["photo"][:tempfile].should be_a(::Tempfile)
    end
  end

end
