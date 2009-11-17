This is a simple test for attributes
*** Parameters: ***
{}
*** Markdown input: ***

Header with attributes	{#header1}	
----------------------

### Header with attributes ###	{#header2}	

### Header no attributes ###

{:warn2}Paragraph with a.
{#par1}

Paragraph with *emphasis*{:hello notfound}
   {#par2}

{:hello: .chello}
*** Output of inspect ***
md_el(:document,[
	md_el(:header,["Header with attributes"],{:level=>2},[[:id, "header1"]]),
	md_el(:header,["Header with attributes"],{:level=>3},[[:id, "header2"]]),
	md_el(:header,["Header no attributes"],{:level=>3},[]),
	md_par(["Paragraph with a."], [[:id, "par1"]]),
	md_par([
		"Paragraph with ",
		md_em(["emphasis"], [[:ref, "hello"], [:ref, "notfound"]])
	], [[:id, "par2"]]),
	md_el(:ald,[],{:ald=>[[:class, "chello"]],:ald_id=>"hello"},[])
],{},[])
*** Output of to_html ***
<h2 id='header1'>Header with attributes</h2>

<h3 id='header2'>Header with attributes</h3>

<h3 id='header_no_attributes'>Header no attributes</h3>

<p id='par1'>Paragraph with a.</p>

<p id='par2'>Paragraph with <em class='chello'>emphasis</em></p>
*** Output of to_latex ***
\hypertarget{header1}{}\subsection*{{Header with attributes}}\label{header1}

\hypertarget{header2}{}\subsubsection*{{Header with attributes}}\label{header2}

\hypertarget{header_no_attributes}{}\subsubsection*{{Header no attributes}}\label{header_no_attributes}

Paragraph with a.

Paragraph with \emph{emphasis}
*** Output of to_md ***
Header with attributesHeader with attributesHeader no attributesParagraph with a.

Paragraph with emphasis
*** Output of to_s ***
Header with attributesHeader with attributesHeader no attributesParagraph with a.Paragraph with emphasis
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)