Write a comment abouth the test here.
*** Parameters: ***
{:css=>"style.css"}
*** Markdown input: ***
CSS: style.css

Input:

	<em>Emphasis</em>

Result: <em>Emphasis</em>

Input:

	<img src="http://jigsaw.w3.org/css-validator/images/vcss"/>

Result on span: <img src="http://jigsaw.w3.org/css-validator/images/vcss"/>

Result alone: 

<img src="http://jigsaw.w3.org/css-validator/images/vcss"/>

Without closing:

<img src="http://jigsaw.w3.org/css-validator/images/vcss">

<div markdown="1">
	This is *true* markdown text (paragraph)

	<p markdown="1">
		This is *true* markdown text (no paragraph)
	</p>
	<p markdown="block">
		This is *true* markdown text (block paragraph)
	</p>
</div>

<table>
<tr>
<td markdown="1">This is a *true* markdown text. (no par)</td>
<td markdown="block">This is *true* markdown text. (par)</td>
</tr>
</table>



*** Output of inspect ***
md_el(:document,[
	md_par(["Input:"]),
	md_el(:code,[],{:raw_code=>"<em>Emphasis</em>"},[]),
	md_par(["Result: ", md_html("<em>Emphasis</em>")]),
	md_par(["Input:"]),
	md_el(:code,[],{:raw_code=>"<img src=\"http://jigsaw.w3.org/css-validator/images/vcss\"/>"},[]),
	md_par([
		"Result on span: ",
		md_html("<img src=\"http://jigsaw.w3.org/css-validator/images/vcss\" />")
	]),
	md_par(["Result alone:"]),
	md_html("<img src=\"http://jigsaw.w3.org/css-validator/images/vcss\" />"),
	md_par(["Without closing:"]),
	md_html("<img src=\"http://jigsaw.w3.org/css-validator/images/vcss\" />"),
	md_html("<div markdown=\"1\">\n\tThis is *true* markdown text (paragraph)\n\n\t<p markdown=\"1\">\n\t\tThis is *true* markdown text (no paragraph)\n\t</p>\n\t<p markdown=\"block\">\n\t\tThis is *true* markdown text (block paragraph)\n\t</p>\n</div>"),
	md_html("<table>\n<tr>\n<td markdown=\"1\">This is a *true* markdown text. (no par)</td>\n<td markdown=\"block\">This is *true* markdown text. (par)</td>\n</tr>\n</table>")
],{},[])
*** Output of to_html ***
<p>Input:</p>

<pre><code>&lt;em&gt;Emphasis&lt;/em&gt;</code></pre>

<p>Result: <em>Emphasis</em></p>

<p>Input:</p>

<pre><code>&lt;img src=&quot;http://jigsaw.w3.org/css-validator/images/vcss&quot;/&gt;</code></pre>

<p>Result on span: <img src='http://jigsaw.w3.org/css-validator/images/vcss' /></p>

<p>Result alone:</p>
<img src='http://jigsaw.w3.org/css-validator/images/vcss' />
<p>Without closing:</p>
<img src='http://jigsaw.w3.org/css-validator/images/vcss' /><div>
<p>
<p>This is</p>
<em>
<p>true</p>
</em>
<p>markdown text (paragraph)</p>
</p>
<p>
<p>
<p>This is</p>
<em>
<p>true</p>
</em>
<p>markdown text (no paragraph)</p>
</p>
</p>
	<p>
<p>
<p>This is</p>
<em>
<p>true</p>
</em>
<p>markdown text (block paragraph)</p>
</p>
</p>
</div><table>
<tr>
<td>
<p>This is a</p>
<em>
<p>true</p>
</em>
<p>markdown text. (no par)</p>
</td>
<td>
<p>This is</p>
<em>
<p>true</p>
</em>
<p>markdown text. (par)</p>
</td>
</tr>
</table>
*** Output of to_latex ***
Input:

\begin{verbatim}<em>Emphasis</em>\end{verbatim}
Result: 

Input:

\begin{verbatim}<img src="http://jigsaw.w3.org/css-validator/images/vcss"/>\end{verbatim}
Result on span: 

Result alone:

Without closing:
*** Output of to_md ***
Input:

Result:

Input:

Result on span:

Result alone:

Without closing:
*** Output of to_s ***
Input:Result: Input:Result on span: Result alone:Without closing:
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)