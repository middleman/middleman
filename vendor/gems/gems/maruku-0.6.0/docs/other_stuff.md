*	*Jan. 22*  With very minimal changes, Maruku now works in JRuby. 
	It is very slow, though.

	Some benchmarks:

	*	G4 1.5GhZ, Ruby 1.8.5:
	
			Maruku (to_html): parsing 0.65 sec + rendering 0.40 sec = 1.04 sec
			Maruku (to_latex): parsing 0.70 sec + rendering 0.21 sec = 0.91 sec

	*	G4 1.5GhZ, JRuby 1.9.2:

			Maruku (to_html): parsing 4.77 sec + rendering 2.24 sec = 7.01 sec
			Maruku (to_latex): parsing 4.04 sec + rendering 1.12 sec = 5.16 sec

*	*Jan. 21*  Integration of Blahtex. PNG export of formula and alignment works
	ok in Mozilla, Safari, Camino, Opera. IE7 is acting strangely.

*	Support for LaTeX-style formula input, and export to MathML. 

	[Jacques Distler] is integrating Maruku into Instiki (a Ruby On Rails-based wiki software), as to have a Ruby wiki with proper math support. You know, these physicists like all those funny symbols.

	*	To have the MathML export, it is needed to install one of:
	
		* 	[RiTeX]   (`gem install ritex`) 
		* 	[itex2MML] supports much more complex formulas than Ritex.
		* 	PNG for old browser is not here yet. The plan is to use
			BlahTeX.


*	Command line options for the `maruku` command:

		Usage: maruku [options] [file1.md [file2.md ...
		    -v, --[no-]verbose               Run verbosely
		    -u, --[no-]unsafe                Use unsafe features
		    -b                               Break on error
		    -m, --math-engine ENGINE         Uses ENGINE to render MathML
		        --pdf                        Write PDF
		        --html                       Write HTML
		        --tex                        Write LaTeX
		        --inspect                    Shows the parsing result
		        --version                    Show version
		    -h, --help                       Show this message

*	Other things:
	
	*	Created the embryo of an extension system. Please don't use it
		yet, as probably the API is bound to change.

	*	There are a couple of hidden, unsafe, features that are not enabled by default.

