


*** Parameters: ***
{}
*** Markdown input: ***
	'Twas a "test" to 'remember' in the '90s.
'Twas a "test" to 'remember' in the '90s.

	It was --- in a sense --- really... interesting.
It was --- in a sense --- really... interesting.

	I -- too -- met << some curly quotes >> there or <<here>>No space.
I -- too -- met << some curly quotes >> there or <<here>>No space.

	
	She was 6\"12\'.
> She was 6\"12\'.

*** Output of inspect ***
md_el(:document,[
	md_el(:code,[],{:raw_code=>"'Twas a \"test\" to 'remember' in the '90s."},[]),
	md_par([
		md_entity("lsquo"),
		"Twas a ",
		md_entity("ldquo"),
		"test",
		md_entity("rdquo"),
		" to ",
		md_entity("lsquo"),
		"remember",
		md_entity("rsquo"),
		" in the ",
		md_entity("rsquo"),
		"90s."
	]),
	md_el(:code,[],{:raw_code=>"It was --- in a sense --- really... interesting."},[]),
	md_par([
		"It was ",
		md_entity("mdash"),
		" in a sense ",
		md_entity("mdash"),
		" really",
		md_entity("hellip"),
		" interesting."
	]),
	md_el(:code,[],{:raw_code=>"I -- too -- met << some curly quotes >> there or <<here>>No space."},[]),
	md_par([
		"I ",
		md_entity("ndash"),
		" too ",
		md_entity("ndash"),
		" met ",
		md_entity("laquo"),
		md_entity("nbsp"),
		"some curly quotes",
		md_entity("nbsp"),
		md_entity("raquo"),
		" there or ",
		md_entity("laquo"),
		"here",
		md_entity("raquo"),
		"No space."
	]),
	md_el(:code,[],{:raw_code=>"She was 6\\\"12\\'."},[]),
	md_el(:quote,[
		md_par(["She was 6", md_entity("quot"), "12", md_entity("apos"), "."])
	],{},[])
],{},[])
*** Output of to_html ***
<pre><code>&#39;Twas a &quot;test&quot; to &#39;remember&#39; in the &#39;90s.</code></pre>

<p>&#8216;Twas a &#8220;test&#8221; to &#8216;remember&#8217; in the &#8217;90s.</p>

<pre><code>It was --- in a sense --- really... interesting.</code></pre>

<p>It was &#8212; in a sense &#8212; really&#8230; interesting.</p>

<pre><code>I -- too -- met &lt;&lt; some curly quotes &gt;&gt; there or &lt;&lt;here&gt;&gt;No space.</code></pre>

<p>I &#8211; too &#8211; met &#171;&#160;some curly quotes&#160;&#187; there or &#171;here&#187;No space.</p>

<pre><code>She was 6\&quot;12\&#39;.</code></pre>

<blockquote>
<p>She was 6&#34;12&#39;.</p>
</blockquote>
*** Output of to_latex ***
\begin{verbatim}'Twas a "test" to 'remember' in the '90s.\end{verbatim}
`{}Twas a ``{}test''{} to `{}remember'{} in the '{}90s.

\begin{verbatim}It was --- in a sense --- really... interesting.\end{verbatim}
It was ---{} in a sense ---{} really\ldots{} interesting.

\begin{verbatim}I -- too -- met << some curly quotes >> there or <<here>>No space.\end{verbatim}
I --{} too --{} met \guillemotleft{}~{}some curly quotes~{}\guillemotright{} there or \guillemotleft{}here\guillemotright{}No space.

\begin{verbatim}She was 6\"12\'.\end{verbatim}
\begin{quote}%
She was 6"{}12'{}.


\end{quote}
*** Output of to_md ***
Twas a test to remember in the 90s.

It was in a sense really interesting.

I too met some curly quotes there or
here No space.

She was 6 12 .
*** Output of to_s ***
Twas a test to remember in the 90s.It was  in a sense  really interesting.I  too  met some curly quotes there or hereNo space.She was 612.
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)