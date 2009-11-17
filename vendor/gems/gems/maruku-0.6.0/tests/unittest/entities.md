Write a comment abouth the test here.
*** Parameters: ***
{}
*** Markdown input: ***
Maruku translates HTML entities to the equivalent in LaTeX:

Entity      | Result
------------|----------
`&copy;`    |  &copy;
`&pound;`   |  &pound;
`a&nbsp;b`  |  a&nbsp;b
`&lambda;`  |  &lambda;
`&mdash;`   |  &mdash;


Entity-substitution does not happen in code blocks or inline code.

The following should not be translated:

	&copy;

It should read just like this: `&copy;`.


*** Output of inspect ***
md_el(:document,[
	md_par(["Maruku translates HTML entities to the equivalent in LaTeX:"]),
	md_el(:table,[
		md_el(:head_cell,["Entity"],{},[]),
		md_el(:head_cell,["Result"],{},[]),
		md_el(:cell,[md_code("&copy;")],{},[]),
		md_el(:cell,[md_entity("copy")],{},[]),
		md_el(:cell,[md_code("&pound;")],{},[]),
		md_el(:cell,[md_entity("pound")],{},[]),
		md_el(:cell,[md_code("a&nbsp;b")],{},[]),
		md_el(:cell,["a", md_entity("nbsp"), "b"],{},[]),
		md_el(:cell,[md_code("&lambda;")],{},[]),
		md_el(:cell,[md_entity("lambda")],{},[]),
		md_el(:cell,[md_code("&mdash;")],{},[]),
		md_el(:cell,[md_entity("mdash")],{},[])
	],{:align=>[:left, :left]},[]),
	md_par([
		"Entity-substitution does not happen in code blocks or inline code."
	]),
	md_par(["The following should not be translated:"]),
	md_el(:code,[],{:raw_code=>"&copy;"},[]),
	md_par(["It should read just like this: ", md_code("&copy;"), "."])
],{},[])
*** Output of to_html ***
<p>Maruku translates HTML entities to the equivalent in LaTeX:</p>
<table><thead><tr><th>Entity</th><th>Result</th></tr></thead><tbody><tr><td style='text-align: left;'><code>&amp;copy;</code></td><td style='text-align: left;'>&#169;</td>
</tr><tr><td style='text-align: left;'><code>&amp;pound;</code></td><td style='text-align: left;'>&#163;</td>
</tr><tr><td style='text-align: left;'><code>a&amp;nbsp;b</code></td><td style='text-align: left;'>a&#160;b</td>
</tr><tr><td style='text-align: left;'><code>&amp;lambda;</code></td><td style='text-align: left;'>&#955;</td>
</tr><tr><td style='text-align: left;'><code>&amp;mdash;</code></td><td style='text-align: left;'>&#8212;</td>
</tr></tbody></table>
<p>Entity-substitution does not happen in code blocks or inline code.</p>

<p>The following should not be translated:</p>

<pre><code>&amp;copy;</code></pre>

<p>It should read just like this: <code>&amp;copy;</code>.</p>
*** Output of to_latex ***
Maruku translates HTML entities to the equivalent in \LaTeX\xspace :

\begin{tabular}{l|l}
Entity&Result\\
\hline 
{\colorbox[rgb]{1.00,0.93,1.00}{\tt \char38copy\char59}}&\copyright{}\\
{\colorbox[rgb]{1.00,0.93,1.00}{\tt \char38pound\char59}}&\pounds{}\\
{\colorbox[rgb]{1.00,0.93,1.00}{\tt a\char38nbsp\char59b}}&a~{}b\\
{\colorbox[rgb]{1.00,0.93,1.00}{\tt \char38lambda\char59}}&$\lambda${}\\
{\colorbox[rgb]{1.00,0.93,1.00}{\tt \char38mdash\char59}}&---{}\\
\end{tabular}

Entity-substitution does not happen in code blocks or inline code.

The following should not be translated:

\begin{verbatim}&copy;\end{verbatim}
It should read just like this: {\colorbox[rgb]{1.00,0.93,1.00}{\tt \char38copy\char59}}.
*** Output of to_md ***
Maruku translates HTML entities to the
equivalent in LaTeX:

EntityResultabEntity-substitution does not happen in
code blocks or inline code.

The following should not be translated:

It should read just like this: .
*** Output of to_s ***
Maruku translates HTML entities to the equivalent in LaTeX:EntityResultabEntity-substitution does not happen in code blocks or inline code.The following should not be translated:It should read just like this: .
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)