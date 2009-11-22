require File.dirname(__FILE__) + '/spec_helper'
require "tempfile"

describe Templater::CLI::Parser do
  describe "given unknown option" do
    it "outputs a meaninful error message instead of just blowing up" do
      lambda do
        Templater::CLI::Parser.parse(["--this-option-is-unknown", "--second-unknown-option"])
      end.should_not raise_error
    end

    it "lists unknown options" do
      e = OptionParser::InvalidOption.new("--this-option-is-unknown", "--second-unknown-option")
      output = Templater::CLI::Parser.error_message(e)

      output.should =~ /--this-option-is-unknown/
      output.should =~ /--second-unknown-option/
    end
  end
end