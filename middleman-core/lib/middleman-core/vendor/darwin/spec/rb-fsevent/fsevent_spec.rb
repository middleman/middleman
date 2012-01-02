require 'spec_helper'

describe FSEvent do

  before(:each) do
    @results = []
    @fsevent = FSEvent.new
    @fsevent.watch @fixture_path.to_s, {:latency => 0.5} do |paths|
      @results += paths
    end
  end

  it "should have a watcher_path that resolves to an executable file" do
    File.exists?(FSEvent.watcher_path).should be_true
    File.executable?(FSEvent.watcher_path).should be_true
  end

  it "should work with path with an apostrophe" do
    custom_path = @fixture_path.join("custom 'path")
    file = custom_path.join("newfile.rb").to_s
    File.delete file if File.exists? file
    @fsevent.watch custom_path.to_s do |paths|
      @results += paths
    end
    @fsevent.paths.should == ["#{custom_path}"]
    run
    FileUtils.touch file
    stop
    File.delete file
    @results.should == [custom_path.to_s + '/']
  end

  it "should catch new file" do
    file = @fixture_path.join("newfile.rb")
    File.delete file if File.exists? file
    run
    FileUtils.touch file
    stop
    File.delete file
    @results.should == [@fixture_path.to_s + '/']
  end

  it "should catch file update" do
    file = @fixture_path.join("folder1/file1.txt")
    File.exists?(file).should be_true
    run
    FileUtils.touch file
    stop
    @results.should == [@fixture_path.join("folder1/").to_s]
  end

  it "should catch files update" do
    file1 = @fixture_path.join("folder1/file1.txt")
    file2 = @fixture_path.join("folder1/folder2/file2.txt")
    File.exists?(file1).should be_true
    File.exists?(file2).should be_true
    run
    FileUtils.touch file1
    FileUtils.touch file2
    stop
    @results.should == [@fixture_path.join("folder1/").to_s, @fixture_path.join("folder1/folder2/").to_s]
  end

  def run
    sleep 1
    Thread.new { @fsevent.run }
    sleep 1
  end

  def stop
    sleep 1
    @fsevent.stop
  end

end
