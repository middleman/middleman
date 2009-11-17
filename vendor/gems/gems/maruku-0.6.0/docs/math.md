Title: Math support in Maruku
LaTeX preamble: math_preamble.tex
LaTeX use listings: true
CSS: math.css style.css
use numbered headers: true

Math support in Maruku
======================

This document describes Maruku's support of inline LaTeX-style math.

At the moment, **these features are experimental**, are probably
buggy and the syntax and implementation are bound to change in
the near future.

Also, there are many subtleties of which one must care for 
correctly serving the XHTML+MathML document to browsers.
In fact, *this documentation is __not__ enough to get you started*, 
unless you feel very adventurous.

* toc
{:toc}

Syntax
---------------------------------------

### Inline math

Inline math is contained inside couples of `$`. 

Everything inside will be passed as-is to LaTeX: no Markdown
interpretation will take place.

	Example: $x^{n}+y^{n} \neq z^{n}$ for $n \geq 3$

> Example: $x^{n}+y^{n} \neq z^{n}$ for $n \geq 3$

### Equations 

Equations are specified using either the `$$ ... $$` or `\[ ... \]`
LaTeX notation. Equations can span multiple lines.

	\[ 
	\sum_{n=1}^\infty \frac{1}{n} 
	\text{ is divergent, but } 
	\lim_{n \to \infty} \sum_{i=1}^n \frac{1}{i} - \ln n \text{exists.} 
	\]

> \[ 
> 	\sum_{n=1}^\infty \frac{1}{n} 
> 	\text{ is divergent, but } 
> 	\lim_{n \to \infty} \sum_{i=1}^n \frac{1}{i} - \ln n \quad \text{exists.} 
> \]

Some random AMSTeX symbols:

	$$ \beth \Subset \bigtriangleup \bumpeq \ggg \pitchfork $$ 

$$ \beth \Subset \bigtriangleup \bumpeq \ggg \pitchfork $$ 


## Cross references ## {#cross}

Create a label for an equation in two ways:

*	LaTeX style:
	
		Consider \eqref{a}:
	
		$$ \alpha = \beta  \label{a} $$

*	More readable style:

		Consider (eq:a):

		$$ \alpha = \beta $$        (a)
	 
You can mix the two.

Labels will work as expected also in the PDF output, whatever
style you use: Maruku will insert the necessary `\label` commands.

The following are 4 equations, labeled A,B,C,D:

$$ \alpha $$ (A)

\[ 
	\beta
\] (B) 

$$ \gamma \label{C} $$

\[ 
	\delta \label{D}
\]

You can now refer to (eq:A), (eq:B), \eqref{C}, \eqref{D}.


Enabling the extension
---------------------------------------

### On the command line 

Use the `-m` option to choose the kind of output. Possible choices are:

`--math-engine itex2mml` : Outputs MathML using [itex2mml](#using_itex2mml).  
`--math-engine ritex` : Outputs MathML using [ritex](#using_ritex).  
`--math-engine blahtex` : Outputs MathML using [blahtex](#using_blahtex).  
`--math-images blahtex` : Outputs PNGs  using [blahtex](#using_blahtex).

### With embedded Maruku

You have to enable the math extension like this:

	require 'maruku'          # loads maruku
	require 'maruku/ext/math' # loads the math extension

Use the following to choose the engine:

	MaRuKu::Globals[:html_math_engine] = 'ritex'
	MaRuKu::Globals[:html_png_engine] =  'blahtex'
	
Available MathML engines are 'none', 'itex2mml', 'blahtex'.
'blahtex' is the only PNG engine available.
	
External libraries needed
-------------------------

To output MathML or PNGs, it is needed to install one of the following libraries

### Using `ritex` ### {#using_ritex}

Install with 

	$ gem install ritex

ritex's abilities are very limited, but it is the easiest to install.

### Using `itex2mml` ### {#using_itex2mml}

itex2mml supports much more LaTeX commands/environments than ritex.

Install itex2mml using the instructions at:

> <http://golem.ph.utexas.edu/~distler/blog/itex2MML.html> 

This is a summary of the available LaTeX commands:

> <http://golem.ph.utexas.edu/~distler/blog/itex2MMLcommands.html>

Moreover, [Jacques Distler] is integrating Maruku+itex2mml+[Instiki].
You can find more information here:

> <http://golem.ph.utexas.edu/~distler/blog/archives/001111.html>

[Jacques Distler]: http://golem.ph.utexas.edu/~distler
[instiki]: http://www.instiki.org

### Using `blahtex` ### {#using_blahtex}

Download from <http://www.blahtex.org>. Make sure you have
the command-line `blahtex` in your path.


Subtleties
----------

### Serving the right content/type ###


* Mozilla wants files to have the `.xhtml` extension.

...

### Where PNGS are put ###

*	`Globals[:math_png_dir]`

*	`Globals[:math_png_dir_url]`


### Styling equations ####

...

### Aligning PNGs ####


*	using `ex`

*	**IE7 bug**

...
