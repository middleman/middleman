module Templater

  ACTION_RESERVED_OPTIONS = [:before, :after].freeze

  class Generator

    include Templater::CaptureHelpers

    class << self

      attr_accessor :manifold


      # Returns an array of hashes, where each hash describes a single argument.
      #
      # === Returns
      # Array[Hash{Symbol=>Object}]:: A list of arguments
      def arguments; @arguments ||= []; end

      # A shorthand method for adding the first argument, see +Templater::Generator.argument+
      def first_argument(*args); argument(0, *args); end

      # A shorthand method for adding the second argument, see +Templater::Generator.argument+
      def second_argument(*args); argument(1, *args); end

      # A shorthand method for adding the third argument, see +Templater::Generator.argument+
      def third_argument(*args); argument(2, *args); end

      # A shorthand method for adding the fourth argument, see +Templater::Generator.argument+
      def fourth_argument(*args); argument(3, *args); end


      # Returns an array of options, where each hash describes a single option.
      #
      # === Returns
      # Array[Hash{Symbol=>Object}]:: A list of options
      def options; @options ||= []; end

      # Returns an array of hashes, where each hash describes a single invocation.
      #
      # === Returns
      # Array[Hash{Symbol=>Object}]:: A list of invocations
      def invocations; @invocations ||= []; end


      # Returns an Hash that maps the type of action to a list of ActionDescriptions.
      #
      # ==== Returns
      # Hash{Symbol=>Array[Templater::ActionDescription]}:: A Hash of actions
      def actions; @actions ||= {} end

      # Returns an array of ActionDescriptions, where each describes a single template.
      #
      # === Returns
      # Array[Templater::ActionDescription]:: A list of template descriptions.
      def templates; actions[:templates] ||= []; end

      # Returns an array of ActionDescriptions, where each describes a single file.
      #
      # === Returns
      # Array[Templater::ActionDescription]:: A list of file descriptions.
      def files; actions[:files] ||= []; end

      # Returns an array of ActionDescriptions, where each describes a single directory.
      #
      # === Returns
      # Array[Templater::ActionDescription]:: A list of file descriptions.
      def directories; actions[:directories] ||= []; end

      # Returns an array of ActionDescriptions, where each describes a single empty directory created by generator.
      #
      # ==== Returns
      # Array[Templater::ActionDescription]:: A list of empty directory descriptions.
      def empty_directories; actions[:empty_directories] ||= []; end


      # If the argument is omitted, simply returns the description for this generator, otherwise
      # sets the description to the passed string.
      #
      # === Parameters
      # text<String>:: A description
      #
      # === Returns
      # String:: The description for this generator
      def desc(text = nil)
        @text = text.realign_indentation if text
        return @text
      end

      # Assign a name to the n:th argument that this generator takes. An accessor
      # with that name will automatically be added to the generator. Options can be provided
      # to ensure the argument conforms to certain requirements. If a block is provided, when an
      # argument is assigned, the block is called with that value and if :invalid is thrown, a proper
      # error is raised
      #
      # === Parameters
      # n<Integer>:: The index of the argument that this describes
      # name<Symbol>:: The name of this argument, an accessor with this name will be created for the argument
      # options<Hash>:: Options for this argument
      # &block<Proc>:: Is evaluated on assignment to check the validity of the argument
      #
      # ==== Options (opts)
      # :default<Object>:: Specify a default value for this argument
      # :as<Symbol>:: If set to :hash or :array, this argument will 'consume' all remaining arguments and bundle them
      #     Use this only for the last argument to this generator.
      # :required<Boolean>:: If set to true, the generator will throw an error if it initialized without this argument
      # :desc<Symbol>:: Provide a description for this argument
      def argument(n, name, options={}, &block)
        self.arguments[n] = ArgumentDescription.new(name.to_sym, options, &block)
        class_eval <<-CLASS
          def #{name}
            get_argument(#{n})
          end

          def #{name}=(arg)
            set_argument(#{n}, arg)
          end
        CLASS
      end

      # Adds an accessor with the given name to this generator, also automatically fills that value through
      # the options hash that is provided when the generator is initialized.
      #
      # === Parameters
      # name<Symbol>:: The name of this option, an accessor with this name will be created for the option
      # options<Hash>:: Options for this option (how meta!)
      #
      # ==== Options (opts)
      # :default<Object>:: Specify a default value for this option
      # :as<Symbol>:: If set to :boolean provides a hint to the interface using this generator.
      # :desc<Symbol>:: Provide a description for this option
      def option(name, options={})
        self.options << Description.new(name.to_sym, options)
        class_eval <<-CLASS
          def #{name}
            get_option(:#{name})
          end

          def #{name}=(arg)
            set_option(:#{name}, arg)
          end
        CLASS
      end

      # Adds an invocation of another generator to this generator. This allows the interface to invoke
      # any templates in that target generator. This requires that the generator is part of a manifold. The name
      # provided is the name of the target generator in this generator's manifold.
      #
      # A hash of options can be passed, all of these options are matched against the options passed to the
      # generator.
      #
      # If a block is given, the generator class is passed to the block, and it is expected that the
      # block yields an instance. Otherwise the target generator is instantiated with the same options and
      # arguments as this generator.
      #
      # === Parameters
      # name<Symbol>:: The name in the manifold of the generator that is to be invoked
      # options<Hash>:: A hash of requirements that are matched against the generator options
      # &block<Proc>:: A block to execute when the generator is instantiated
      #
      # ==== Examples
      #
      #   class MyGenerator < Templater::Generator
      #     invoke :other_generator
      #   end
      #
      #   class MyGenerator < Templater::Generator
      #     def random
      #       rand(100000).to_s
      #     end
      #
      #     # invoke :other_generator with some
      #     invoke :other_generator do |generator|
      #       generator.new(destination_root, options, random)
      #     end
      #   end
      #
      #   class MyGenerator < Templater::Generator
      #     option :animal
      #     # other_generator will be invoked only if the option 'animal' is set to 'bear'
      #     invoke :other_generator, :animal => :bear
      #   end
      def invoke(name, options={}, &block)
        self.invocations << InvocationDescription.new(name.to_sym, options, &block)
      end

      # Adds a template to this generator. Templates are named and can later be retrieved by that name.
      # Templates have a source and a destination. When a template is invoked, the source file is rendered,
      # passing through ERB, and the result is copied to the destination. Source and destination can be
      # specified in different ways, and are always assumed to be relative to source_root and destination_root.
      #
      # If only a destination is given, the source is assumed to be the same destination, only appending the
      # letter 't', so a destination of 'app/model.rb', would assume a source of 'app/model.rbt'
      #
      # Source and destination can be set in a block, which makes it possible to call instance methods to
      # determine the correct source and/or desination.
      #
      # A hash of options can be passed, these options are matched against the options passed to the
      # generator. Some special options, for callbacks for example, are also supported, see below.
      #
      # === Parameters
      # name<Symbol>:: The name of this template
      # source<String>:: The source template, can be omitted
      # destination<String>:: The destination where the result will be put.
      # options<Hash>:: Options for this template
      # &block<Proc>:: A block to execute when the generator is instantiated
      #
      # === Options
      # :before<Symbol>:: Name of a method to execute before this template is invoked
      # :after<Symbol>:: Name of a method to execute after this template is invoked
      #
      # ==== Examples
      #
      #   class MyGenerator < Templater::Generator
      #     def random
      #       rand(100000).to_s
      #     end
      #
      #     template :one, 'template.rb' # source will be inferred as 'template.rbt'
      #     template :two, 'source.rbt', 'template.rb' # source expicitly given
      #     template :three do
      #       source('source.rbt')
      #       destination("#{random}.rb")
      #     end
      #   end
      def template(name, *args, &block)
        options = args.last.is_a?(Hash) ? args.pop : {}
        source, destination = args
        source, destination = source + 't', source if args.size == 1

        templates << ActionDescription.new(name, options) do |generator|
          template = Actions::Template.new(generator, name, source, destination, options)
          generator.instance_exec(template, &block) if block
          template
        end
      end

      # Adds a template that is not rendered using ERB, but copied directly. Unlike Templater::Generator.template
      # this will not append a 't' to the source, otherwise it works identically.
      #
      # === Parameters
      # name<Symbol>:: The name of this template
      # source<String>:: The source template, can be omitted
      # destination<String>:: The destination where the result will be put.
      # options<Hash>:: Options for this template
      # &block<Proc>:: A block to execute when the generator is instantiated
      #
      # === Options
      # :before<Symbol>:: Name of a method to execute before this template is invoked
      # :after<Symbol>:: Name of a method to execute after this template is invoked
      def file(name, *args, &block)
        options = args.last.is_a?(Hash) ? args.pop : {}
        source, destination = args
        source, destination = source, source if args.size == 1

        files << ActionDescription.new(name, options) do |generator|
          file = Actions::File.new(generator, name, source, destination, options)
          generator.instance_exec(file, &block) if block
          file
        end
      end

      # Adds a directory that is copied directly. This method is usedful
      # when globbing is not exactly what you want, or you need to access
      # options to decide what source or destination should be.
      #
      # === Parameters
      # name<Symbol>:: The name of this template
      # source<String>:: The source template, can be omitted
      # destination<String>:: The destination where the result will be put.
      # options<Hash>:: Options for this template
      # &block<Proc>:: A block to execute when the generator is instantiated
      #
      # === Options
      # :before<Symbol>:: Name of a method to execute before this template is invoked
      # :after<Symbol>:: Name of a method to execute after this template is invoked
      def directory(name, *args, &block)
        options = args.last.is_a?(Hash) ? args.pop : {}
        source, destination = args
        source, destination = source, source if args.size == 1

        directories << ActionDescription.new(name, options) do |generator|
          directory = Actions::Directory.new(generator, name, source, destination, options)
          generator.instance_exec(directory, &block) if block
          directory
        end
      end

      # Adds an empty directory that will be created when the generator is run.
      #
      # === Parameters
      # name<Symbol>:: The name of this empty directory
      # destination<String>:: The destination where the empty directory will be created
      # options<Hash>:: Options for this empty directory
      # &block<Proc>:: A block to execute when the generator is instantiated
      #
      # === Options
      # :before<Symbol>:: Name of a method to execute before this template is invoked
      # :after<Symbol>:: Name of a method to execute after this template is invoked
      def empty_directory(name, *args, &block)
        options = args.last.is_a?(Hash) ? args.pop : {}
        destination = args.first

        empty_directories << ActionDescription.new(name, options) do |generator|
          directory = Actions::EmptyDirectory.new(generator, name, destination, options)
          generator.instance_exec(directory, &block) if block
          directory
        end
      end

      # An easy way to add many templates to a generator, each item in the list is added as a
      # template. The provided list can be either an array of Strings or a Here-Doc with templates
      # on individual lines.
      #
      # === Parameters
      # list<String|Array>:: A list of templates to be added to this generator
      #
      # === Examples
      #
      #   class MyGenerator < Templater::Generator
      #     template_list <<-LIST
      #       path/to/template1.rb
      #       another/template.css
      #     LIST
      #     template_list ['a/third/template.rb', 'and/a/fourth.js']
      #   end
      def template_list(list)
        list = list.to_lines if list.is_a?(String)
        list.each do |item|
          item = item.to_s.chomp.strip
          self.template(item.gsub(/[\.\/]/, '_').to_sym, item)
        end
      end

      # An easy way to add many non-rendering templates to a generator. The provided list can be either an
      # array of Strings or a Here-Doc with templates on individual lines.
      #
      # === Parameters
      # list<String|Array>:: A list of non-rendering templates to be added to this generator
      #
      # === Examples
      #
      #   class MyGenerator < Templater::Generator
      #     file_list <<-LIST
      #       path/to/file.jpg
      #       another/file.html.erb
      #     LIST
      #     file_list ['a/third/file.gif', 'and/a/fourth.rb']
      #   end
      def file_list(list)
        list = list.to_lines if list.is_a?(String)
        list.each do |item|
          item = item.to_s.chomp.strip
          self.file(item.gsub(/[\.\/]/, '_').to_sym, item)
        end
      end

      # An easy way to add many non-rendering templates to a generator. The provided list can be either an
      # array of Strings or a Here-Doc with templates on individual lines.
      #
      # === Parameters
      # list<String|Array>:: A list of non-rendering templates to be added to this generator
      #
      # === Examples
      #
      #   class MyGenerator < Templater::Generator
      #     directory_list <<-LIST
      #       path/to/directory
      #       another/directory
      #     LIST
      #     directory_list ['a/third/directory', 'and/a/fourth']
      #   end
      def directory_list(list)
        list = list.to_lines if list.is_a?(String)
        list.each do |item|
          item = item.to_s.chomp.strip
          self.directory(item.gsub(/[\.\/]/, '_').to_sym, item)
        end
      end


      # Search a directory for templates and files and add them to this generator. Any file
      # whose extension matches one of those provided in the template_extensions parameter
      # is considered a template and will be rendered with ERB, all others are considered
      # normal files and are simply copied.
      #
      # A hash of options can be passed which will be assigned to each file and template.
      # All of these options are matched against the options passed to the generator.
      #
      # === Parameters
      # source<String>:: The directory to search in, relative to the source_root, if omitted
      #     the source root itself is searched.
      # template_destination<Array[String]>:: A list of extensions. If a file has one of these
      #     extensions, it is considered a template and will be rendered with ERB.
      # options<Hash{Symbol=>Object}>:: A list of options.
      def glob!(dir = nil, template_extensions = %w(rb css js erb html yml Rakefile TODO LICENSE README), options={})
        ::Dir[::File.join(source_root, dir.to_s, '**/*')].each do |action|
          unless ::File.directory?(action)
            action = action.sub("#{source_root}/", '')

            if template_extensions.include?(::File.extname(action.sub(/\.%.+%$/,''))[1..-1]) or template_extensions.include?(::File.basename(action))
              template(action.downcase.gsub(/[^a-z0-9]+/, '_').to_sym, action, action)
            else
              file(action.downcase.gsub(/[^a-z0-9]+/, '_').to_sym, action, action)
            end
          end
        end
      end

      # Returns a list of the classes of all generators (recursively) that are invoked together with this one.
      #
      # === Returns
      # Array[Templater::Generator]:: an array of generator classes.
      def generators
        generators = [self]
        if manifold
          generators += invocations.map do |i|
            generator = manifold.generator(i.name)
            generator ? generator.generators : nil
          end
        end
        generators.flatten.compact
      end

      # This should return the directory where source templates are located. This method must be overridden in
      # any Generator inheriting from Templater::Source.
      #
      # === Raises
      # Templater::SourceNotSpecifiedError:: Always raises this error, so be sure to override this method.
      def source_root
        raise Templater::SourceNotSpecifiedError, "Subclasses of Templater::Generator must override the source_root method, to specify where source templates are located."
      end

    end # end of eigenclass


    #
    # ==== Instance methods
    #

    attr_accessor :destination_root, :arguments, :options

    # Create a new generator. Checks the list of arguments agains the requirements set using +argument+.
    #
    # === Parameters
    # destination_root<String>:: The destination, where the generated files will be put.
    # options<Hash{Symbol => Symbol}>:: Options given to this generator.
    # *arguments<String>:: The list of arguments. These must match the declared requirements.
    #
    # === Raises
    # Templater::ArgumentError:: If the arguments are invalid
    def initialize(destination_root, options = {}, *args)
      @destination_root = destination_root
      @arguments = []
      @options = options

      # Initialize options to their default values.
      self.class.options.each do |option|
        @options[option.name] ||= option.options[:default]
      end

      args.each_with_index do |arg, n|
        set_argument(n, arg)
      end

      self.class.arguments.each_with_index do |argument, i|
        # Initialize arguments to their default values.
        @arguments[i] ||= argument.options[:default]
        # Check if all arguments are valid.
        argument.valid?(@arguments[i])
      end
    end

    # Finds and returns the template of the given name. If that template's options don't match the generator
    # options, returns nil.
    #
    # === Parameters
    # name<Symbol>:: The name of the template to look up.
    #
    # === Returns
    # Templater::Actions::Template:: The found template.
    def template(name)
      templates.find { |t| t.name == name }
    end

    # Finds and returns the file of the given name. If that file's options don't match the generator
    # options, returns nil.
    #
    # === Parameters
    # name<Symbol>:: The name of the file to look up.
    #
    # === Returns
    # Templater::Actions::File:: The found file.
    def file(name)
      files.find { |f| f.name == name }
    end

    # Finds and returns all empty directories whose options match the generator options.
    #
    # === Returns
    # [Templater::Actions::EmptyDirectory]:: The found empty directories that generator creates.
    def empty_directory(name)
      empty_directories.find { |d| d.name == name }
    end

    # Finds and returns all templates whose options match the generator options.
    #
    # === Returns
    # [Templater::Actions::Template]:: The found templates.
    def templates
      actions(:templates)
    end

    # Finds and returns all files whose options match the generator options.
    #
    # === Returns
    # [Templater::Actions::File]:: The found files.
    def files
      actions(:files)
    end

    # Finds and returns all empty directories generator creates.
    #
    # === Returns
    # [Templater::Actions::File]:: The found files.
    def empty_directories
      actions(:empty_directories)
    end

    # Finds and returns all templates whose options match the generator options.
    #
    # === Returns
    # [Templater::Generator]:: The found templates.
    def invocations
      return [] unless self.class.manifold

      self.class.invocations.map do |invocation|
        invocation.get(self) if match_options?(invocation.options)
      end.compact
    end

    # Finds and returns all templates and files for this generators whose options match its options.
    #
    # === Parameters
    # type<Symbol>:: The type of actions to look up (optional)
    # === Returns
    # [Templater::Actions::*]:: The found templates and files.
    def actions(type=nil)
      actions = type ? self.class.actions[type] : self.class.actions.values.flatten
      actions.inject([]) do |actions, description|
        actions << description.compile(self) if match_options?(description.options)
        actions
      end
    end

    # Finds and returns all templates and files for this generators and any of those generators it invokes,
    # whose options match that generator's options.
    #
    # === Returns
    # [Templater::Actions::File, Templater::Actions::Template]:: The found templates and files.
    def all_actions(type=nil)
      all_actions = actions(type)
      all_actions += invocations.map { |i| i.all_actions(type) }
      all_actions.flatten
    end

    # Invokes the templates for this generator
    def invoke!
      all_actions.each { |t| t.invoke! }
    end

    # Renders all actions in this generator. Use this to verify that rendering templates raises no errors.
    #
    # === Returns
    # [String]:: The results of the rendered actions
    def render!
      all_actions.map { |t| t.render }
    end

    # Returns this generator's source root
    #
    # === Returns
    # String:: The source root of this generator.
    #
    # === Raises
    # Templater::SourceNotSpecifiedError:: IF the source_root class method has not been overridden.
    def source_root
      self.class.source_root
    end

    # Returns the destination root that is given to the generator on initialization. If the generator is a
    # command line program, this would usually be Dir.pwd.
    #
    # === Returns
    # String:: The destination root
    def destination_root
      @destination_root # just here so it can be documented.
    end

    def after_run
      # override in subclasses if necessary
    end

    def after_generation
      # override in subclasses if necessary
    end

    def after_deletion
      # override in subclasses if necessary
    end

    protected

    def set_argument(n, value)
      expected = self.class.arguments[n]
      raise Templater::TooManyArgumentsError, "This generator does not take this many Arguments" if expected.nil?

      value = expected.extract(value)

      expected.valid?(value)
      @arguments[n] = value
    end

    def get_argument(n)
      @arguments[n]
    end

    def set_option(name, value)
      @options[name] = value
    end

    def get_option(name)
      @options[name]
    end

    def match_options?(options)
      options.all? do |key, value|
        key.to_sym.in?(Templater::ACTION_RESERVED_OPTIONS) or self.send(key) == value
      end
    end

  end

end
