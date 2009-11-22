module FSSM::Support
  class << self
    def backend
      (mac? && carbon_core?) ? 'FSEvents' : 'Polling'
    end

    def mac?
      @@mac ||= RUBY_PLATFORM =~ /darwin/i
    end

    def carbon_core?
      @@carbon_core ||= begin
        require 'osx/foundation'
        OSX.require_framework '/System/Library/Frameworks/CoreServices.framework/Frameworks/CarbonCore.framework'
        true
      rescue LoadError
        false
      end
    end

  end
end
