# encoding: utf-8
class Thor
  module Actions
    class GenerateFile < CreateFile
      def on_conflict_behavior(&block)
        if identical?
          say_status :identical, :blue
        else
          options = base.options.merge(config)
          force_or_skip_or_conflict(options[:force], options[:skip], &block)
        end
      end
    end
  end
end

class Thor
  module Actions
    def generate_file(destination, *args, &block)
      config = args.last.is_a?(Hash) ? args.pop : {}
      data = args.first
      action GenerateFile.new(self, destination, block || data.to_s, config)
    end
  end
end
