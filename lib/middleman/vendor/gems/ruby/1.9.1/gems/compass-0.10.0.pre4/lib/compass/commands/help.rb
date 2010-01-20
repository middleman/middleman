module Compass
  module Commands
    module HelpOptionsParser
      def set_options(opts)
        banner = %Q{Usage: compass help [command]

Description:
  The Compass Stylesheet Authoring Framework helps you
  build and maintain your stylesheets and makes it easy
  for you to use stylesheet libraries provided by others.

To get help on a particular command please specify the command.

}
        
        primary_commands = Compass::Commands.all.select do |c|
          cmd = Compass::Commands[c]
          cmd.respond_to?(:primary) && cmd.primary
        end
        other_commands = Compass::Commands.all - primary_commands

        banner << command_list("Primary Commands:", primary_commands)
        banner << command_list("Other Commands:", other_commands)
 
        banner << "\nAvailable Frameworks & Patterns:\n\n"
        Compass::Frameworks::ALL.each do |framework|
          banner << "  * #{framework.name}\n"
          framework.template_directories.each do |pattern|
            banner << "    - #{framework.name}/#{pattern}"
            if description = framework.manifest(pattern).description
              banner << "\t- #{description}"
            end
            banner << "\n"
          end
        end

        opts.banner = banner

        super
      end

      def command_list(header, commands)
        list = "#{header}\n"
        commands.sort_by{|c| c.to_s}.each do |command|
          list << "  * #{command}"
          if Compass::Commands[command].respond_to? :description
            list << "\t- #{Compass::Commands[command].description(command)}"
          end
          list << "\n"
        end
        list
      end
    end
    class Help < Base
      register :help
      
      class << self
        def option_parser(arguments)
          parser = Compass::Exec::CommandOptionParser.new(arguments)
          parser.extend(HelpOptionsParser)
        end
        def usage
          option_parser([]).to_s
        end
        def description(command)
          "Get help on a compass command or extension"
        end
        def parse!(arguments)
          parser = option_parser(arguments)
          parser.parse!
          parser.options[:help_command] = arguments.shift || 'help'
          parser.options
        end
      end

      def execute
        if Compass::Commands.command_exists? options[:help_command]
          $command = options[:help_command]
          puts Compass::Commands[options[:help_command]].usage
          $command = "help"
        elsif Compass::Frameworks.template_exists? options[:help_command]
          puts Compass::Frameworks.template_usage(options[:help_command])
        else
          raise OptionParser::ParseError, "No such command: #{options[:help_command]}"
        end
      end
    end
  end
end
