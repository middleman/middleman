#Using Treetop Grammars in Ruby
##Using the Command Line Compiler
You can `.treetop` files into Ruby source code with the `tt` command line script. `tt` takes an list of files with a `.treetop` extension and compiles them into `.rb` files of the same name. You can then `require` these files like any other Ruby script. Alternately, you can supply just one `.treetop` file and a `-o` flag to name specify the name of the output file. Improvements to this compilation script are welcome.

    tt foo.treetop bar.treetop
    tt foo.treetop -o foogrammar.rb

##Loading A Grammar Directly
The Polyglot gem makes it possible to load `.treetop` or `.tt` files directly with `require`. This will invoke `Treetop.load`, which automatically compiles the grammar to Ruby and then evaluates the Ruby source. If you are getting errors in methods you define on the syntax tree, try using the command line compiler for better stack trace feedback. A better solution to this issue is in the works.

##Instantiating and Using Parsers
If a grammar by the name of `Foo` is defined, the compiled Ruby source will define a `FooParser` class. To parse input, create an instance and call its `parse` method with a string. The parser will return the syntax tree of the match or `nil` if there is a failure.

    Treetop.load "arithmetic"
    
    parser = ArithmeticParser.new
    if parser.parse('1+1')
      puts 'success'
    else
      puts 'failure'
    end
