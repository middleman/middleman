module Compass
  module TestCaseHelper
    def absolutize(path)
      if path.blank?
        File.dirname(__FILE__)
      elsif path[0] == ?/
        "#{File.dirname(__FILE__)}#{path}"
      else
        "#{File.dirname(__FILE__)}/#{path}"
      end
    end
  end
end
