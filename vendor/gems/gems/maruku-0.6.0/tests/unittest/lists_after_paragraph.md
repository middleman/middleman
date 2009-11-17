This should not trigger the list
*** Parameters: ***
{}
*** Markdown input: ***
Paragraph, list with no space:
* ciao

Paragraph, list with 1 space:
 * ciao

Paragraph, list with 3 space:
   * ciao

Paragraph, list with 4 spaces:
    * ciao

Paragraph, list with 1 tab:
	* ciao

Paragraph (1 space after), list with no space: 
* ciao

Paragraph (2 spaces after), list with no space:  
* ciao

Paragraph (3 spaces after), list with no space:   
* ciao

Paragraph with block quote:
> Quoted

Paragraph with header:
### header ###

Paragraph with header on two lines:
header
------


Paragraph with html after
<div></div>

Paragraph with html after, indented:
     <em>Emphasis</em>

Paragraph with html after, indented: <em>Emphasis</em> *tralla* <em>Emph</em>

Paragraph with html after, indented: <em>Emphasis *tralla* Emph</em>

*** Output of inspect ***
md_el(:document,[
	md_par(["Paragraph, list with no space: * ciao"]),
	md_par(["Paragraph, list with 1 space: * ciao"]),
	md_par(["Paragraph, list with 3 space: * ciao"]),
	md_par(["Paragraph, list with 4 spaces: * ciao"]),
	md_par(["Paragraph, list with 1 tab: * ciao"]),
	md_par(["Paragraph (1 space after), list with no space: * ciao"]),
	md_par([
		"Paragraph (2 spaces after), list with no space:",
		md_el(:linebreak,[],{},[]),
		"* ciao"
	]),
	md_par([
		"Paragraph (3 spaces after), list with no space: ",
		md_el(:linebreak,[],{},[]),
		"* ciao"
	]),
	md_par(["Paragraph with block quote:"]),
	md_el(:quote,[md_par(["Quoted"])],{},[]),
	md_par(["Paragraph with header:"]),
	md_el(:header,["header"],{:level=>3},[]),
	md_par(["Paragraph with header on two lines:"]),
	md_el(:header,["header"],{:level=>2},[]),
	md_par(["Paragraph with html after ", md_html("<div></div>")]),
	md_par([
		"Paragraph with html after, indented: ",
		md_html("<em>Emphasis</em>")
	]),
	md_par([
		"Paragraph with html after, indented: ",
		md_html("<em>Emphasis</em>"),
		" ",
		md_em(["tralla"]),
		" ",
		md_html("<em>Emph</em>")
	]),
	md_par([
		"Paragraph with html after, indented: ",
		md_html("<em>Emphasis *tralla* Emph</em>")
	])
],{},[])
*** Output of to_html ***
<p>Paragraph, list with no space: * ciao</p>

<p>Paragraph, list with 1 space: * ciao</p>

<p>Paragraph, list with 3 space: * ciao</p>

<p>Paragraph, list with 4 spaces: * ciao</p>

<p>Paragraph, list with 1 tab: * ciao</p>

<p>Paragraph (1 space after), list with no space: * ciao</p>

<p>Paragraph (2 spaces after), list with no space:<br />* ciao</p>

<p>Paragraph (3 spaces after), list with no space: <br />* ciao</p>

<p>Paragraph with block quote:</p>

<blockquote>
<p>Quoted</p>
</blockquote>

<p>Paragraph with header:</p>

<h3 id='header'>header</h3>

<p>Paragraph with header on two lines:</p>

<h2 id='header'>header</h2>

<p>Paragraph with html after <div /></p>

<p>Paragraph with html after, indented: <em>Emphasis</em></p>

<p>Paragraph with html after, indented: <em>Emphasis</em> <em>tralla</em> <em>Emph</em></p>

<p>Paragraph with html after, indented: <em>Emphasis *tralla* Emph</em></p>
*** Output of to_latex ***
Paragraph, list with no space: * ciao

Paragraph, list with 1 space: * ciao

Paragraph, list with 3 space: * ciao

Paragraph, list with 4 spaces: * ciao

Paragraph, list with 1 tab: * ciao

Paragraph (1 space after), list with no space: * ciao

Paragraph (2 spaces after), list with no space:\newline * ciao

Paragraph (3 spaces after), list with no space: \newline * ciao

Paragraph with block quote:

\begin{quote}%
Quoted


\end{quote}
Paragraph with header:

\hypertarget{header}{}\subsubsection*{{header}}\label{header}

Paragraph with header on two lines:

\hypertarget{header}{}\subsection*{{header}}\label{header}

Paragraph with html after 

Paragraph with html after, indented: 

Paragraph with html after, indented:  \emph{tralla} 

Paragraph with html after, indented:
*** Output of to_md ***
Paragraph, list with no space: * ciao

Paragraph, list with 1 space: * ciao

Paragraph, list with 3 space: * ciao

Paragraph, list with 4 spaces: * ciao

Paragraph, list with 1 tab: * ciao

Paragraph (1 space after), list with no
space: * ciao

Paragraph (2 spaces after), list with
no space:  
* ciao

Paragraph (3 spaces after), list with
no space:  
* ciao

Paragraph with block quote:

Quoted

Paragraph with header:

headerParagraph with header on two lines:

headerParagraph with html after

Paragraph with html after, indented:

Paragraph with html after, indented:
tralla

Paragraph with html after, indented:
*** Output of to_s ***
Paragraph, list with no space: * ciaoParagraph, list with 1 space: * ciaoParagraph, list with 3 space: * ciaoParagraph, list with 4 spaces: * ciaoParagraph, list with 1 tab: * ciaoParagraph (1 space after), list with no space: * ciaoParagraph (2 spaces after), list with no space:* ciaoParagraph (3 spaces after), list with no space: * ciaoParagraph with block quote:QuotedParagraph with header:headerParagraph with header on two lines:headerParagraph with html after Paragraph with html after, indented: Paragraph with html after, indented:  tralla Paragraph with html after, indented:
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)