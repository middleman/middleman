Write a comment abouth the test here.
*** Parameters: ***
{}
*** Markdown input: ***
> Code
>
>     Ciao
*** Output of inspect ***
md_el(:document,[
	md_el(:quote,[md_par(["Code"]), md_el(:code,[],{:raw_code=>"Ciao"},[])],{},[])
],{},[])
*** Output of to_html ***
<blockquote>
<p>Code</p>

<pre><code>Ciao</code></pre>
</blockquote>
*** Output of to_latex ***
\begin{quote}%
Code

\begin{verbatim}Ciao\end{verbatim}

\end{quote}
*** Output of to_md ***
Code
*** Output of to_s ***
Code
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)