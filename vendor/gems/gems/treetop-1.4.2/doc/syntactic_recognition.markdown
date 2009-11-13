#Syntactic Recognition 
Treetop grammars are written in a custom language based on parsing expression grammars. Literature on the subject of <a href="http://en.wikipedia.org/wiki/Parsing_expression_grammar">parsing expression grammars</a> is useful in writing Treetop grammars.

#Grammar Structure
Treetop grammars look like this:

    grammar GrammarName
      rule rule_name
        ...
      end
      
      rule rule_name
        ...
      end
      
      ...
    end

The main keywords are:

* `grammar` : This introduces a new grammar. It is followed by a constant name to which the grammar will be bound when it is loaded.

* `rule` : This defines a parsing rule within the grammar. It is followed by a name by which this rule can be referenced within other rules. It is then followed by a parsing expression defining the rule.

#Parsing Expressions
Each rule associates a name with a _parsing expression_. Parsing expressions are a generalization of vanilla regular expressions. Their key feature is the ability to reference other expressions in the grammar by name.

##Terminal Symbols
###Strings
Strings are surrounded in double or single quotes and must be matched exactly.

* `"foo"`
* `'foo'`
  
###Character Classes
Character classes are surrounded by brackets. Their semantics are identical to those used in Ruby's regular expressions.

* `[a-zA-Z]`
* `[0-9]`

###The Anything Symbol
The anything symbol is represented by a dot (`.`) and matches any single character.

##Nonterminal Symbols
Nonterminal symbols are unquoted references to other named rules. They are equivalent to an inline substitution of the named expression.

    rule foo
      "the dog " bar
    end
    
    rule bar
      "jumped"
    end

The above grammar is equivalent to:

    rule foo
      "the dog jumped"
    end

##Ordered Choice
Parsers attempt to match ordered choices in left-to-right order, and stop after the first successful match.

    "foobar" / "foo" / "bar"
    
Note that if `"foo"` in the above expression came first, `"foobar"` would never be matched.

##Sequences

Sequences are a space-separated list of parsing expressions. They have higher precedence than choices, so choices must be parenthesized to be used as the elements of a sequence. 

    "foo" "bar" ("baz" / "bop")

##Zero or More
Parsers will greedily match an expression zero or more times if it is followed by the star (`*`) symbol.

* `'foo'*` matches the empty string, `"foo"`, `"foofoo"`, etc.

##One or More
Parsers will greedily match an expression one or more times if it is followed by the star (`+`) symbol.

* `'foo'+` does not match the empty string, but matches `"foo"`, `"foofoo"`, etc.

##Optional Expressions
An expression can be declared optional by following it with a question mark (`?`).

* `'foo'?` matches `"foo"` or the empty string.

##Lookahead Assertions
Lookahead assertions can be used to give parsing expressions a limited degree of context-sensitivity. The parser will look ahead into the buffer and attempt to match an expression without consuming input.

###Positive Lookahead Assertion
Preceding an expression with an ampersand `(&)` indicates that it must match, but no input will be consumed in the process of determining whether this is true.

* `"foo" &"bar"` matches `"foobar"` but only consumes up to the end `"foo"`. It will not match `"foobaz"`.

###Negative Lookahead Assertion
Preceding an expression with a bang `(!)` indicates that the expression must not match, but no input will be consumed in the process of determining whether this is true.

* `"foo" !"bar"` matches `"foobaz"` but only consumes up to the end `"foo"`. It will not match `"foobar"`.
