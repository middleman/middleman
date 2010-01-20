module Templater

  module CLI

    class Manifold

      def initialize(destination_root, manifold, name, version)
        @destination_root, @manifold, @name, @version = destination_root, manifold, name, version
      end

      def version
        puts @version
        exit
      end

      def self.run(destination_root, manifold, name, version, arguments)
        if arguments.blank? || (arguments.first && ["help", "-h", "--help"].include?(arguments.first))
          Manifold.new(destination_root, manifold, name, version).run(arguments)
          return
        end

        generator_name = arguments.shift
        if generator_class = manifold.generator(generator_name)
          Generator.new(generator_name, generator_class, destination_root, name, version).run(arguments)
        else
          Manifold.new(destination_root, manifold, name, version).run(arguments)
        end
      end

      def run(arguments)
        @options = Templater::CLI::Parser.parse(arguments)
        self.help
      end

      # outputs a helpful message and quits
      def help
        puts "Usage: #{@name} generator_name [options] [args]"
        puts ''
        puts @manifold.desc
        puts ''
        puts 'Available generators'
        @manifold.public_generators.sort do |one, other|
          one[0].to_s <=> other[0].to_s
        end.each do |name, generator|
          print "    "
          print name.to_s.ljust(33)
          print generator.desc.to_lines.first.chomp if generator.desc
          print "\n"
        end
        puts @options[:opts]
        puts ''
        exit
      end

    end

  end

end
