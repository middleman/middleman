CSS: style.css
LaTeX CJK: true
HTML use syntax: true

<!-- #### Changes in the development version (**not yet released**)  ####     {#last} -->

#### Changes in 0.5.6  ####     {#stable}

*	News:

	-	Now Maruku is in the official Gentoo Portage tree (done by [Aggelos Orfanakos])
	
*	New stuff: 

	- Attribute `maruku_signature` defaults to false. (many people asked this)
	- unittests scripts are included in the distribution.
	- New attribute `filter_html`: if true, raw HTML/XML is discarded. (asked by Marik)
	- Command line: if output file is `-`, Maruku writes to stdout.

*	Bug fixes:

	*	Another tiny bug in HTML parsing.
	*	In latex, `\linebreak` was used instead of `\newline` (reported by Sam Kleinman)
	*	Fixed bug with non-alpha numeric characters in ref.ids (reported by Aggelos Orfanakos)

	
*	Pending bugs/feature requests:

	- Maruku does not allow 3-space indented lists.
	- Lists item whose first character is UTF8 are not recognized (reported by Aggelos Orfanakos)
	- Maruku cannot output `"`-delimited attributes, because `REXML` does not support it.
	
[Aggelos Orfanakos]: http://agorf.gr/

#### Changes in 0.5.5  ####    

*	Features:

	*	Input of HTML numeric entities:
	
			Examples of numeric character references include &#169; or &#xA9; 
			for the copyright symbol, &#913; or &#x391; for the Greek capital 
			letter alpha, and &#1575; or &#x627; for the Arabic letter alef.

		> Examples of numeric character references include &#169; or &#xA9; 
		> for the copyright symbol, &#913; or &#x391; for the Greek capital 
		> letter alpha, and &#1575; or &#x627; for the Arabic letter alef.

*	Bug fixes:
	
	*	Alt text was ignored for images.
	*	Fixed minor bug in reading HTML inside paragraph.
	*	Changed rules for block-level HTML to make it similar to Markdown.pl. 
		For example:
		
			Paragraph
			<div></div>
		
		will be translated to 

			<p>Paragraph
			<div></div></p>
			
		while this:
			
			Paragraph
			
			<div></div>
		
		becomes
		
			<p>Paragraph</p>
		
			<div></div>

*	**Pending bugs**: there are some problems when parsing lists. It is difficult
	to get it right because the spec is very fuzzy. At the moment, list items 
	cannot be indented by more than 1 space.

#### Changes in 0.5.4 ####  

*	Features:

	*	[All HTML attributes](http://www.w3.org/TR/html4/index/attributes.html) are supported. 
	
			>  Science is a wonderful thing if one does not
			>  have to earn one's living at it.
			{: cite="http://en.wikiquote.org/wiki/Albert_Einstein"}

	*	Attribute `doc_prefix`.
	
	*	Math:
		
		*	`\begin{equation}` and `\end{equation}` are understood.
		*	Math parsing enabled per-instance using the `math_enabled` attribute.
		*	`math_numbered` attribute.
		
*	Bug fixes:

	*	Runs quietly with `ruby -w`.
	*	Fixed a bug which could cause data-loss when reading indented lines.


#### Changes in 0.5.3 ####  

*	Features:

	*	[All HTML `table` attributes](http://www.w3.org/TR/html4/struct/tables.html#h-11.2.1)
		can be used (`summary`, `width`, `frame`, `rules`,
		`border`, `cellspacing`, `cellpadding`).
		
		The next version will hopefully use all HTML attributes.
		

	<!-- A version of Markdown that is more Japanese or something --> 
	
*	Bug fixes:

	*	Crash on this line: (found by Aggelos Orfanakos) 
	
			[test][]:
	
	*	Regression with attribute system (found by Charles)

#### Changes in 0.5.1 ####    

*	Bug fixes:
	
	*	Workaround for Internet Explorer bug: 
		be very sure that `&apos;` is always written as `&#39;`.
		
	*	Support for empty images ref: `![image]` and `![image][]`.

	*	Fixed bug in parsing attribute lists definitions.

*	Minor things:
	
	*	Now code blocks are written as a `<code>` element inside a `<pre>`, and
		`<code>` elements have both `class` and `lang` attributes set 
		to the specified language.
		
		Example:

			    Example
			{:lang=ruby}
		{:lang=markdown}
		
		produces:
		
			<pre><code class='ruby' lang='ruby'>Example</code></pre>
		{:lang=xml}
		
#### Changes in 0.5.0 ####  

*	Syntax changes:

	*	Compatibility with newest Markdown.pl: `[text]` as a synonim of `[text][]`.

	*	Meta data: the first IAL in a span environment now refers to the parent.
		This makes it possible to set attributes for cells:

			Head           |  Head |
			---------------+-------+--
			{:r}  Hello    + ...

			{:r: scope='row'}

		The first cell will have the `scope` attribute set to `row`.

*	New settings:

	*	Disable the Maruku signature by setting `maruku signature: false`

*	Stricter doctype. By the way -- did I mention it? -- 
	**Maruku HTML has always been proper validating XHTML strict** 
	(if a page does not validate, please report it as a bug).

	Of course, this only matters when using `maruku` as a standalone
	program.

	*	I have updated the XHTML DTD used to support MathML: 
		currently using XHTML+MathML+SVG.
	*	Content-type set to `application/xhtml+xml`	
	*	All entities are written as numeric entities.

*	Bug fixes

	*	Many fixes in the code handling the sanitizing of inline HTML.
	*	`markdown=1` did not propagate to children.
	*	LaTeX: An exception was raised if an unknown entity was used.

#### Changes in 0.4.2 ####    

*	Adapted syntax to the [new meta-data proposal][proposal].

*	Changes in LaTeX export: 

	*	Links to external URLs are blue by default.

	*	New attributes: `latex_preamble` to add a custom preamble,
		and `latex_cjk` to add packages for UTF-8 Japanese characters.
		(**support for this is still shaky**). Example:
	
			Title: my document
			LaTeX CJK: true
			LaTeX preamble: preamble.tex
		
			Content

*	Bug fixes

	+ Images were not given `id` or `class` attributes.

	+ Fixed bug in LaTeX export with handling of `<`,`>` enclosed URLs: `<google.com>`.

#### Changes in 0.4.1 aka "Typographer" ####

*	Implemented SmartyPants support:

		'Twas a "test" to 'remember' -- in the '90s 
		--- while I was <<ok>>. She was 6\"12\'.
	> 'Twas a "test" to 'remember' -- in the '90s --- while I was <<ok>>.
	> She was 6\"12\'.

	I adapted the code from RubyPants.
	
*	Server directives between `<? ?>` are properly preserved.
*	Changes in LaTeX export:

	*	Now Japanese text rendering sort of works, using the following packages:

			\usepackage[C40]{fontenc}
			\usepackage[cjkjis]{ucs}
			\usepackage[utf8x]{inputenc}
		
		Nevertheless, I could only get bitmap fonts working -- probably it's a problem
		with my setup.

		A quick test: 日本、中国、ひらがな、カタカナ。

	*	Fixed bugs in rendering of immediate links.
	*	External packages are `require`d only if needed.
	*	More symbols supported.
		See the symbol list 
		[in HTML](http://maruku.rubyforge.org/entity_test.html) and
		[in PDF](http://maruku.rubyforge.org/entity_test.pdf).


#### Changes in 0.4 ####

* First implementation of [the new meta-data syntax][meta].
* General refactorization of the code and much cleaner error reporting.
* Created [the RDOC documentation][rdoc].
* The `add_whitespace` method took too much time -- it was O(n^2).
* Added unit-tests for block-level elements.

[rdoc]: http://maruku.rubyforge.org/rdoc/
[meta]: http://maruku.rubyforge.org/proposal.html



[Jacques Distler]: http://golem.ph.utexas.edu/~distler
[itex2MML]:  http://golem.ph.utexas.edu/~distler/blog/itex2MML.html
[math]: http://rubyforge.maruku.org/math.html


#### Changes in 0.3 ####

*	A real parser is used instead of a regexp-based system, also for span-level 
	elements.

	Now Maruku is almost 2x faster than Bluecloth, while having more features.

	Here are some benchmarks:
	
		BlueCloth (to_html): parsing 0.00 sec + rendering 1.54 sec = 1.55 sec 
		Maruku (to_html):    parsing 0.47 sec + rendering 0.38 sec = 0.85 sec 
		Maruku (to_latex):   parsing 0.49 sec + rendering 0.25 sec = 0.73 sec
		
	This is the result of running `lib/maruku/tests/benchmark.rb` on the Markdown 
	specification.

*	Prettier HTML output by adding whitespace.
 
*	Added a full suite of unit-tests for the span-level parser.

*	Error management: Having a real parser, Maruku warns you about syntax issues.
	
	The default action is to warn and try to continue. If you do this:

		Maruku.new(string, {:on_error => :raise})

	then syntax errors will cause an exception to be raised (you can catch this
	and retry).

*	Fixed a series of bugs in handling inline HTML code.

Immediate TODO-list:

*	UTF-8 input/output works OK for HTML, however I am having pain trying to export
	to LaTeX. I want at least Japanese characters support, so if you know how to 
	do this you are very welcome to give me an hand.
	
	For example: in the HTML version, you should see accented characters in this
	parenthesis: 
	
	> (àèìòù)
	
	and Japanese text in these other parentheses: 
	
	> (カタカナで 私の 名前は アンドレア チェンシ です).
	>
	> (日本のガルは 大好き、でも、日本語は難しですから、そうぞ 英語話すガルを おしえてください).
	
	In the LaTeX version, these do not appear. I know how to do LaTeX with 
	ISO-8859-1 encoding (European characters), but I'm struggling with half-baked 
	solutions for UTF-8 encoded documents.

*	Implement the [new meta-data proposal][proposal].

*	Exporting to Markdown (pretty printing).

*	Exporting to HTML splitting in multiple files.

*	RubyPants.

*	Support for images in PDF.


[proposal]: http://maruku.rubyforge.org/proposal.html
[contact]: http://www.dis.uniroma1.it/~acensi/contact.html
[markdown-discuss]: http://six.pairlist.net/mailman/listinfo/markdown-discuss
[tracker]: http://rubyforge.org/tracker/?group_id=2795

