# require File.join(File.dirname(__FILE__), "spec_helper")
# 
# base = ::Middleman::Base
# base.set :root, File.join(File.dirname(__FILE__), "fixtures", "sample")
# 
# describe "Relative Assets Feature" do
#   before do
#     base.disable :relative_assets
#     base.init!
#     @app = base.new
#   end
#   
#   it "should not contain ../ if off" do
#     @app.asset_url("stylesheets/static.css").should_not include("?")
#   end
# end
# 
# describe "Relative Assets Feature" do
#   before do
#     base.enable :relative_assets
#     base.init!
#     @app = base.new
#   end
#   
#   it "should contain ../ if on" do
#     @app.asset_url("stylesheets/static.css").should include("?")
#   end
# end