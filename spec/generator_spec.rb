require 'fileutils'

describe "Generator" do
  def project_file(*parts)
    File.expand_path(File.join(File.dirname(__FILE__), "..", *parts))
  end
  
  before :all do
    @root_dir = project_file("spec", "fixtures", "generator-test")
  end
  
  before :each do
    init_cmd = project_file("bin", "mm-init")
    `cd #{File.dirname(@root_dir)} && #{init_cmd} #{File.basename(@root_dir)}`
  end
  
  after :each do
    FileUtils.rm_rf(@root_dir)
  end
  
  it "should copy template files" do
    template_dir = project_file("lib", "template", "**/*")
    Dir[template_dir].each do |f|
      next if File.directory?(f)
      File.exists?("#{@root_dir}/#{f.split('template/')[1]}").should be_true
    end
  end
  
  it "should create empty directories" do
    %w(views/stylesheets public/stylesheets public/javascripts public/images).each do |d|
      File.exists?("#{@root_dir}/#{d}").should be_true
    end
  end
end