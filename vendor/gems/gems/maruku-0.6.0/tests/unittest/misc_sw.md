Write a comment abouth the test here.
*** Parameters: ***
{:archive=>false, :date=>"Nov 20 2006", :inmenu=>true, :subject_short=>"painless software", :subject=>"Software not painful to use", :topic=>"/misc/coolsw", :order=>"-9.5"}
*** Markdown input: ***
Subject: Software not painful to use
Subject_short: painless software
Topic: /misc/coolsw
Archive: no
Date: Nov 20 2006
Order: -9.5
inMenu: true


### General ###

* *Operating System* : [Mac OS X][switch]: heaven, after the purgatory of Linux 
  and the hell of Windows.
* *Browser*: [Firefox][firefox]. On a Mac, [Camino][camino].
* *Email*: [GMail][gmail], "search, don't sort" really works.
* *Text Editor*: [TextMate][textmate], you have to buy it, but it's worth every
  penny. There are rumours that it's been converting (recovering) Emacs
  users (addicts). Unfortunately, it's Mac only. An alternative is
  [jedit][jedit] (GPL, Java).

### Development ###

* *Build system*: [cmake][cmake], throw the [autotools][autotools] away.
* *Source code control system*: ditch CVS for [subversion][subversion].
* *Project management*: [Trac][trac] tracks everything.
* *Scripting language*: [Ruby][ruby] is Japanese pragmatism (and has a [poignant][poignant] guide). 
   Python, you say? Python is too academic and snob:

      $ python       
      Python 2.4.1 (\#1, Jun  4 2005, 00:54:33) 
      Type "help", "copyright", "credits" or "license" for more information.
      >>> exit
      'Use Ctrl-D (i.e. EOF) to exit.'
      >>> quit
      'Use Ctrl-D (i.e. EOF) to exit.'

* *Java IDE*: [JBuilder][jbuilder] is great software and has a free version (IMHO better than Eclipse). Java
 is not a pain anymore since it gained [generics][java-generics] and got opensourced.
* *Mark-up language*: HTML is so 2001, why don't you take at look at [Markdown][markdown]? [Look at the source of this page](data/misc_markdown.png).
* *C++ libraries*: 
    * [QT][qt] for GUIs.
    * [GSL][gsl] for math.
    * [Magick++][magick] for manipulating images.
    * [Cairo][cairo] for creating PDFs.
    * [Boost][boost] for just about everything else.


### Research ###

* *Writing papers*: [LaTeX][latex]
* *Writing papers & enjoying the process*: [LyX][lyx]
* *Handsome figures in your papers*: [xfig][xfig] or, better, [jfig][jfig].
* *The occasional presentation with many graphical content*: 
  [OpenOffice Impress][impress] (using the [OOOlatex plugin][ooolatex]); 
  the alternative is PowerPoint with the [TexPoint][texpoint] plugin.
* *Managing BibTeX*: [jabref][jabref]: multi-platform, for all your bibtex needs.
* *IEEExplore and BibTeX*: convert citations using [BibConverter][bibconverter].

### Cool websites ###

* *Best site in the wwworld*: [Wikipedia][wikipedia]
* [Mutopia][mutopia] for sheet music; [the Gutenberg Project][gutenberg] for books; [LiberLiber][liberliber] for books in italian.
* *Blogs*: [Bloglines][bloglines]
* *Sharing photos*: [flickr][flickr] exposes an API you can use.


[firefox]:   http://getfirefox.com/
[gmail]:     http://gmail.com/
[bloglines]: http://bloglines.com/
[wikipedia]: http://en.wikipedia.org/
[ruby]:      http://www.ruby-lang.org/
[poignant]:  http://poignantguide.net/ruby/
[webgen]:    http://webgen.rubyforge.org/
[markdown]:  http://daringfireball.net/projects/markdown/
[latex]:     http://en.wikipedia.org/wiki/LaTeX
[lyx]:       http://www.lyx.org
[impress]:   http://www.openoffice.org/product/impress.html
[ooolatex]:  http://ooolatex.sourceforge.net/
[texpoint]:  http://texpoint.necula.org/
[jabref]:    http://jabref.sourceforge.net/
[camino]:    http://www.caminobrowser.org/
[switch]:    http://www.apple.com/getamac/
[textmate]:  http://www.apple.com/getamac/
[cmake]:     http://www.cmake.org/
[xfig]:      http://www.xfig.org/
[jfig]:         http://tams-www.informatik.uni-hamburg.de/applets/jfig/
[subversion]:   http://subversion.tigris.org
[jbuilder]:     http://www.borland.com/us/products/jbuilder/index.html
[flickr]:       http://www.flickr.com/
[myflickr]:     http://www.flickr.com/photos/censi
[bibconverter]: http://www.bibconverter.net/ieeexplore/
[autotools]:    http://sources.redhat.com/autobook/
[jedit]:        http://www.jedit.org/
[qt]:           http://www.trolltech.no/
[gsl]:          http://www.gnu.org/software/gsl/
[magick]:       http://www.imagemagick.org/Magick++/
[cairo]:        http://cairographics.org/
[boost]:        http://www.boost.org/
[markdown]:     http://en.wikipedia.org/wiki/Markdown
[trac]:         http://trac.edgewall.org/
[mutopia]:      http://www.mutopiaproject.org/
[liberliber]:   http://www.liberliber.it/
[gutenberg]:    http://www.gutenberg.org/
[java-generics]: http://java.sun.com/j2se/1.5.0/docs/guide/language/generics.html


*** Output of inspect ***
md_el(:document,[
	md_el(:header,["General"],{:level=>3},[]),
	md_el(:ul,[
		md_el(:li_span,[
			md_em(["Operating System"]),
			" : ",
			md_link(["Mac OS X"],"switch"),
			": heaven, after the purgatory of Linux and the hell of Windows."
		],{:want_my_paragraph=>false},[]),
		md_el(:li_span,[
			md_em(["Browser"]),
			": ",
			md_link(["Firefox"],"firefox"),
			". On a Mac, ",
			md_link(["Camino"],"camino"),
			"."
		],{:want_my_paragraph=>false},[]),
		md_el(:li_span,[
			md_em(["Email"]),
			": ",
			md_link(["GMail"],"gmail"),
			", ",
			md_entity("ldquo"),
			"search, don",
			md_entity("rsquo"),
			"t sort",
			md_entity("rdquo"),
			" really works."
		],{:want_my_paragraph=>false},[]),
		md_el(:li_span,[
			md_em(["Text Editor"]),
			": ",
			md_link(["TextMate"],"textmate"),
			", you have to buy it, but it",
			md_entity("rsquo"),
			"s worth every penny. There are rumours that it",
			md_entity("rsquo"),
			"s been converting (recovering) Emacs users (addicts). Unfortunately, it",
			md_entity("rsquo"),
			"s Mac only. An alternative is ",
			md_link(["jedit"],"jedit"),
			" (GPL, Java)."
		],{:want_my_paragraph=>false},[])
	],{},[]),
	md_el(:header,["Development"],{:level=>3},[]),
	md_el(:ul,[
		md_el(:li,[
			md_par([
				md_em(["Build system"]),
				": ",
				md_link(["cmake"],"cmake"),
				", throw the ",
				md_link(["autotools"],"autotools"),
				" away."
			])
		],{:want_my_paragraph=>false},[]),
		md_el(:li,[
			md_par([
				md_em(["Source code control system"]),
				": ditch CVS for ",
				md_link(["subversion"],"subversion"),
				"."
			])
		],{:want_my_paragraph=>false},[]),
		md_el(:li,[
			md_par([
				md_em(["Project management"]),
				": ",
				md_link(["Trac"],"trac"),
				" tracks everything."
			])
		],{:want_my_paragraph=>false},[]),
		md_el(:li,[
			md_par([
				md_em(["Scripting language"]),
				": ",
				md_link(["Ruby"],"ruby"),
				" is Japanese pragmatism (and has a ",
				md_link(["poignant"],"poignant"),
				" guide). Python, you say? Python is too academic and snob:"
			]),
			md_el(:code,[],{:raw_code=>"$ python       \nPython 2.4.1 (\\#1, Jun  4 2005, 00:54:33) \nType \"help\", \"copyright\", \"credits\" or \"license\" for more information.\n>>> exit\n'Use Ctrl-D (i.e. EOF) to exit.'\n>>> quit\n'Use Ctrl-D (i.e. EOF) to exit.'"},[])
		],{:want_my_paragraph=>true},[]),
		md_el(:li,[
			md_par([
				md_em(["Java IDE"]),
				": ",
				md_link(["JBuilder"],"jbuilder"),
				" is great software and has a free version (IMHO better than Eclipse). Java is not a pain anymore since it gained ",
				md_link(["generics"],"javagenerics"),
				" and got opensourced."
			])
		],{:want_my_paragraph=>false},[]),
		md_el(:li,[
			md_par([
				md_em(["Mark-up language"]),
				": HTML is so 2001, why don",
				md_entity("rsquo"),
				"t you take at look at ",
				md_link(["Markdown"],"markdown"),
				"? ",
				md_im_link(["Look at the source of this page"], "data/misc_markdown.png", nil),
				"."
			])
		],{:want_my_paragraph=>false},[]),
		md_el(:li,[
			md_par([
				md_em(["C++ libraries"]),
				": * ",
				md_link(["QT"],"qt"),
				" for GUIs. * ",
				md_link(["GSL"],"gsl"),
				" for math. * ",
				md_link(["Magick++"],"magick"),
				" for manipulating images. * ",
				md_link(["Cairo"],"cairo"),
				" for creating PDFs. * ",
				md_link(["Boost"],"boost"),
				" for just about everything else."
			])
		],{:want_my_paragraph=>false},[])
	],{},[]),
	md_el(:header,["Research"],{:level=>3},[]),
	md_el(:ul,[
		md_el(:li_span,[md_em(["Writing papers"]), ": ", md_link(["LaTeX"],"latex")],{:want_my_paragraph=>false},[]),
		md_el(:li_span,[
			md_em(["Writing papers & enjoying the process"]),
			": ",
			md_link(["LyX"],"lyx")
		],{:want_my_paragraph=>false},[]),
		md_el(:li_span,[
			md_em(["Handsome figures in your papers"]),
			": ",
			md_link(["xfig"],"xfig"),
			" or, better, ",
			md_link(["jfig"],"jfig"),
			"."
		],{:want_my_paragraph=>false},[]),
		md_el(:li_span,[
			md_em(["The occasional presentation with many graphical content"]),
			": ",
			md_link(["OpenOffice Impress"],"impress"),
			" (using the ",
			md_link(["OOOlatex plugin"],"ooolatex"),
			"); the alternative is PowerPoint with the ",
			md_link(["TexPoint"],"texpoint"),
			" plugin."
		],{:want_my_paragraph=>false},[]),
		md_el(:li_span,[
			md_em(["Managing BibTeX"]),
			": ",
			md_link(["jabref"],"jabref"),
			": multi-platform, for all your bibtex needs."
		],{:want_my_paragraph=>false},[]),
		md_el(:li_span,[
			md_em(["IEEExplore and BibTeX"]),
			": convert citations using ",
			md_link(["BibConverter"],"bibconverter"),
			"."
		],{:want_my_paragraph=>false},[])
	],{},[]),
	md_el(:header,["Cool websites"],{:level=>3},[]),
	md_el(:ul,[
		md_el(:li_span,[
			md_em(["Best site in the wwworld"]),
			": ",
			md_link(["Wikipedia"],"wikipedia")
		],{:want_my_paragraph=>false},[]),
		md_el(:li_span,[
			md_link(["Mutopia"],"mutopia"),
			" for sheet music; ",
			md_link(["the Gutenberg Project"],"gutenberg"),
			" for books; ",
			md_link(["LiberLiber"],"liberliber"),
			" for books in italian."
		],{:want_my_paragraph=>false},[]),
		md_el(:li_span,[md_em(["Blogs"]), ": ", md_link(["Bloglines"],"bloglines")],{:want_my_paragraph=>false},[]),
		md_el(:li_span,[
			md_em(["Sharing photos"]),
			": ",
			md_link(["flickr"],"flickr"),
			" exposes an API you can use."
		],{:want_my_paragraph=>false},[])
	],{},[]),
	md_ref_def("firefox", "http://getfirefox.com/", {:title=>nil}),
	md_ref_def("gmail", "http://gmail.com/", {:title=>nil}),
	md_ref_def("bloglines", "http://bloglines.com/", {:title=>nil}),
	md_ref_def("wikipedia", "http://en.wikipedia.org/", {:title=>nil}),
	md_ref_def("ruby", "http://www.ruby-lang.org/", {:title=>nil}),
	md_ref_def("poignant", "http://poignantguide.net/ruby/", {:title=>nil}),
	md_ref_def("webgen", "http://webgen.rubyforge.org/", {:title=>nil}),
	md_ref_def("markdown", "http://daringfireball.net/projects/markdown/", {:title=>nil}),
	md_ref_def("latex", "http://en.wikipedia.org/wiki/LaTeX", {:title=>nil}),
	md_ref_def("lyx", "http://www.lyx.org", {:title=>nil}),
	md_ref_def("impress", "http://www.openoffice.org/product/impress.html", {:title=>nil}),
	md_ref_def("ooolatex", "http://ooolatex.sourceforge.net/", {:title=>nil}),
	md_ref_def("texpoint", "http://texpoint.necula.org/", {:title=>nil}),
	md_ref_def("jabref", "http://jabref.sourceforge.net/", {:title=>nil}),
	md_ref_def("camino", "http://www.caminobrowser.org/", {:title=>nil}),
	md_ref_def("switch", "http://www.apple.com/getamac/", {:title=>nil}),
	md_ref_def("textmate", "http://www.apple.com/getamac/", {:title=>nil}),
	md_ref_def("cmake", "http://www.cmake.org/", {:title=>nil}),
	md_ref_def("xfig", "http://www.xfig.org/", {:title=>nil}),
	md_ref_def("jfig", "http://tams-www.informatik.uni-hamburg.de/applets/jfig/", {:title=>nil}),
	md_ref_def("subversion", "http://subversion.tigris.org", {:title=>nil}),
	md_ref_def("jbuilder", "http://www.borland.com/us/products/jbuilder/index.html", {:title=>nil}),
	md_ref_def("flickr", "http://www.flickr.com/", {:title=>nil}),
	md_ref_def("myflickr", "http://www.flickr.com/photos/censi", {:title=>nil}),
	md_ref_def("bibconverter", "http://www.bibconverter.net/ieeexplore/", {:title=>nil}),
	md_ref_def("autotools", "http://sources.redhat.com/autobook/", {:title=>nil}),
	md_ref_def("jedit", "http://www.jedit.org/", {:title=>nil}),
	md_ref_def("qt", "http://www.trolltech.no/", {:title=>nil}),
	md_ref_def("gsl", "http://www.gnu.org/software/gsl/", {:title=>nil}),
	md_ref_def("magick", "http://www.imagemagick.org/Magick++/", {:title=>nil}),
	md_ref_def("cairo", "http://cairographics.org/", {:title=>nil}),
	md_ref_def("boost", "http://www.boost.org/", {:title=>nil}),
	md_ref_def("markdown", "http://en.wikipedia.org/wiki/Markdown", {:title=>nil}),
	md_ref_def("trac", "http://trac.edgewall.org/", {:title=>nil}),
	md_ref_def("mutopia", "http://www.mutopiaproject.org/", {:title=>nil}),
	md_ref_def("liberliber", "http://www.liberliber.it/", {:title=>nil}),
	md_ref_def("gutenberg", "http://www.gutenberg.org/", {:title=>nil}),
	md_ref_def("javagenerics", "http://java.sun.com/j2se/1.5.0/docs/guide/language/generics.html", {:title=>nil})
],{},[])
*** Output of to_html ***
<h3 id='general'>General</h3>

<ul>
<li><em>Operating System</em> : <a href='http://www.apple.com/getamac/'>Mac OS X</a>: heaven, after the purgatory of Linux and the hell of Windows.</li>

<li><em>Browser</em>: <a href='http://getfirefox.com/'>Firefox</a>. On a Mac, <a href='http://www.caminobrowser.org/'>Camino</a>.</li>

<li><em>Email</em>: <a href='http://gmail.com/'>GMail</a>, &#8220;search, don&#8217;t sort&#8221; really works.</li>

<li><em>Text Editor</em>: <a href='http://www.apple.com/getamac/'>TextMate</a>, you have to buy it, but it&#8217;s worth every penny. There are rumours that it&#8217;s been converting (recovering) Emacs users (addicts). Unfortunately, it&#8217;s Mac only. An alternative is <a href='http://www.jedit.org/'>jedit</a> (GPL, Java).</li>
</ul>

<h3 id='development'>Development</h3>

<ul>
<li>
<p><em>Build system</em>: <a href='http://www.cmake.org/'>cmake</a>, throw the <a href='http://sources.redhat.com/autobook/'>autotools</a> away.</p>
</li>

<li>
<p><em>Source code control system</em>: ditch CVS for <a href='http://subversion.tigris.org'>subversion</a>.</p>
</li>

<li>
<p><em>Project management</em>: <a href='http://trac.edgewall.org/'>Trac</a> tracks everything.</p>
</li>

<li>
<p><em>Scripting language</em>: <a href='http://www.ruby-lang.org/'>Ruby</a> is Japanese pragmatism (and has a <a href='http://poignantguide.net/ruby/'>poignant</a> guide). Python, you say? Python is too academic and snob:</p>

<pre><code>$ python       
Python 2.4.1 (\#1, Jun  4 2005, 00:54:33) 
Type &quot;help&quot;, &quot;copyright&quot;, &quot;credits&quot; or &quot;license&quot; for more information.
&gt;&gt;&gt; exit
&#39;Use Ctrl-D (i.e. EOF) to exit.&#39;
&gt;&gt;&gt; quit
&#39;Use Ctrl-D (i.e. EOF) to exit.&#39;</code></pre>
</li>

<li>
<p><em>Java IDE</em>: <a href='http://www.borland.com/us/products/jbuilder/index.html'>JBuilder</a> is great software and has a free version (IMHO better than Eclipse). Java is not a pain anymore since it gained <a href='http://java.sun.com/j2se/1.5.0/docs/guide/language/generics.html'>generics</a> and got opensourced.</p>
</li>

<li>
<p><em>Mark-up language</em>: HTML is so 2001, why don&#8217;t you take at look at <a href='http://en.wikipedia.org/wiki/Markdown'>Markdown</a>? <a href='data/misc_markdown.png'>Look at the source of this page</a>.</p>
</li>

<li>
<p><em>C++ libraries</em>: * <a href='http://www.trolltech.no/'>QT</a> for GUIs. * <a href='http://www.gnu.org/software/gsl/'>GSL</a> for math. * <a href='http://www.imagemagick.org/Magick++/'>Magick++</a> for manipulating images. * <a href='http://cairographics.org/'>Cairo</a> for creating PDFs. * <a href='http://www.boost.org/'>Boost</a> for just about everything else.</p>
</li>
</ul>

<h3 id='research'>Research</h3>

<ul>
<li><em>Writing papers</em>: <a href='http://en.wikipedia.org/wiki/LaTeX'>LaTeX</a></li>

<li><em>Writing papers &amp; enjoying the process</em>: <a href='http://www.lyx.org'>LyX</a></li>

<li><em>Handsome figures in your papers</em>: <a href='http://www.xfig.org/'>xfig</a> or, better, <a href='http://tams-www.informatik.uni-hamburg.de/applets/jfig/'>jfig</a>.</li>

<li><em>The occasional presentation with many graphical content</em>: <a href='http://www.openoffice.org/product/impress.html'>OpenOffice Impress</a> (using the <a href='http://ooolatex.sourceforge.net/'>OOOlatex plugin</a>); the alternative is PowerPoint with the <a href='http://texpoint.necula.org/'>TexPoint</a> plugin.</li>

<li><em>Managing BibTeX</em>: <a href='http://jabref.sourceforge.net/'>jabref</a>: multi-platform, for all your bibtex needs.</li>

<li><em>IEEExplore and BibTeX</em>: convert citations using <a href='http://www.bibconverter.net/ieeexplore/'>BibConverter</a>.</li>
</ul>

<h3 id='cool_websites'>Cool websites</h3>

<ul>
<li><em>Best site in the wwworld</em>: <a href='http://en.wikipedia.org/'>Wikipedia</a></li>

<li><a href='http://www.mutopiaproject.org/'>Mutopia</a> for sheet music; <a href='http://www.gutenberg.org/'>the Gutenberg Project</a> for books; <a href='http://www.liberliber.it/'>LiberLiber</a> for books in italian.</li>

<li><em>Blogs</em>: <a href='http://bloglines.com/'>Bloglines</a></li>

<li><em>Sharing photos</em>: <a href='http://www.flickr.com/'>flickr</a> exposes an API you can use.</li>
</ul>
*** Output of to_latex ***
\hypertarget{general}{}\subsubsection*{{General}}\label{general}

\begin{itemize}%
\item \emph{Operating System} : \href{http://www.apple.com/getamac/}{Mac OS X}: heaven, after the purgatory of Linux and the hell of Windows.
\item \emph{Browser}: \href{http://getfirefox.com/}{Firefox}. On a Mac, \href{http://www.caminobrowser.org/}{Camino}.
\item \emph{Email}: \href{http://gmail.com/}{GMail}, ``{}search, don'{}t sort''{} really works.
\item \emph{Text Editor}: \href{http://www.apple.com/getamac/}{TextMate}, you have to buy it, but it'{}s worth every penny. There are rumours that it'{}s been converting (recovering) Emacs users (addicts). Unfortunately, it'{}s Mac only. An alternative is \href{http://www.jedit.org/}{jedit} (GPL, Java).

\end{itemize}
\hypertarget{development}{}\subsubsection*{{Development}}\label{development}

\begin{itemize}%
\item \emph{Build system}: \href{http://www.cmake.org/}{cmake}, throw the \href{http://sources.redhat.com/autobook/}{autotools} away.


\item \emph{Source code control system}: ditch CVS for \href{http://subversion.tigris.org}{subversion}.


\item \emph{Project management}: \href{http://trac.edgewall.org/}{Trac} tracks everything.


\item \emph{Scripting language}: \href{http://www.ruby-lang.org/}{Ruby} is Japanese pragmatism (and has a \href{http://poignantguide.net/ruby/}{poignant} guide). Python, you say? Python is too academic and snob:

\begin{verbatim}$ python       
Python 2.4.1 (\#1, Jun  4 2005, 00:54:33) 
Type "help", "copyright", "credits" or "license" for more information.
>>> exit
'Use Ctrl-D (i.e. EOF) to exit.'
>>> quit
'Use Ctrl-D (i.e. EOF) to exit.'\end{verbatim}

\item \emph{Java IDE}: \href{http://www.borland.com/us/products/jbuilder/index.html}{JBuilder} is great software and has a free version (IMHO better than Eclipse). Java is not a pain anymore since it gained \href{http://java.sun.com/j2se/1.5.0/docs/guide/language/generics.html}{generics} and got opensourced.


\item \emph{Mark-up language}: HTML is so 2001, why don'{}t you take at look at \href{http://en.wikipedia.org/wiki/Markdown}{Markdown}? \href{data/misc_markdown.png}{Look at the source of this page}.


\item \emph{C++ libraries}: * \href{http://www.trolltech.no/}{QT} for GUIs. * \href{http://www.gnu.org/software/gsl/}{GSL} for math. * \href{http://www.imagemagick.org/Magick++/}{Magick++} for manipulating images. * \href{http://cairographics.org/}{Cairo} for creating PDFs. * \href{http://www.boost.org/}{Boost} for just about everything else.



\end{itemize}
\hypertarget{research}{}\subsubsection*{{Research}}\label{research}

\begin{itemize}%
\item \emph{Writing papers}: \href{http://en.wikipedia.org/wiki/LaTeX}{LaTeX}
\item \emph{Writing papers \& enjoying the process}: \href{http://www.lyx.org}{LyX}
\item \emph{Handsome figures in your papers}: \href{http://www.xfig.org/}{xfig} or, better, \href{http://tams-www.informatik.uni-hamburg.de/applets/jfig/}{jfig}.
\item \emph{The occasional presentation with many graphical content}: \href{http://www.openoffice.org/product/impress.html}{OpenOffice Impress} (using the \href{http://ooolatex.sourceforge.net/}{OOOlatex plugin}); the alternative is PowerPoint with the \href{http://texpoint.necula.org/}{TexPoint} plugin.
\item \emph{Managing BibTeX}: \href{http://jabref.sourceforge.net/}{jabref}: multi-platform, for all your bibtex needs.
\item \emph{IEEExplore and BibTeX}: convert citations using \href{http://www.bibconverter.net/ieeexplore/}{BibConverter}.

\end{itemize}
\hypertarget{cool_websites}{}\subsubsection*{{Cool websites}}\label{cool_websites}

\begin{itemize}%
\item \emph{Best site in the wwworld}: \href{http://en.wikipedia.org/}{Wikipedia}
\item \href{http://www.mutopiaproject.org/}{Mutopia} for sheet music; \href{http://www.gutenberg.org/}{the Gutenberg Project} for books; \href{http://www.liberliber.it/}{LiberLiber} for books in italian.
\item \emph{Blogs}: \href{http://bloglines.com/}{Bloglines}
\item \emph{Sharing photos}: \href{http://www.flickr.com/}{flickr} exposes an API you can use.

\end{itemize}
*** Output of to_md ***
General-perating System: Mac OS X: heaven,
after the purgatory of Linux and
the hell of Windows.
-rowser: Firefox. On a Mac, Camino.
-mail: GMail, search, don t sort
really works.
-ext Editor: TextMate, you have to
buy it, but it s worth every penny.
There are rumours that it s been
converting (recovering) Emacs users
(addicts). Unfortunately, it s Mac
only. An alternative is jedit(GPL,
Java).

Development-Build system: cmake, throw the autotools away.
-Source code control system: ditch CVS for subversion.
-Project management: Trac tracks everything.
-Scripting language: Ruby is Japanese pragmatism (and has a poignant guide). Python, you say? Python is too academic and snob:
-Java IDE: JBuilder is great software and has a free version (IMHO better than Eclipse). Java is not a pain anymore since it gained generics and got opensourced.
-Mark-up language: HTML is so 2001, why dont you take at look at Markdown? Look at the source of this page.
-C++ libraries: * QT for GUIs. * GSL for math. * Magick++ for manipulating images. * Cairo for creating PDFs. * Boost for just about everything else.

Research-riting papers: LaTeX
-Writing papers & enjoying the process
: LyX
-andsome figures in your papers:
xfigor, better, jfig.
-The occasional presentation with many graphical content
: OpenOffice Impress(using the
OOOlatex plugin); the alternative
is PowerPoint with the TexPoint
plugin.
-anaging BibTeX: jabref:
multi-platform, for all your bibtex
needs.
-EEExplore and BibTeX: convert
citations using BibConverter.

Cool websites-est site in the wwworld: Wikipedia
-utopiafor sheet music;
the Gutenberg Projectfor books;
LiberLiberfor books in italian.
-logs: Bloglines
-haring photos: flickrexposes an
API you can use.
*** Output of to_s ***
GeneralOperating System : Mac OS X: heaven, after the purgatory of Linux and the hell of Windows.Browser: Firefox. On a Mac, Camino.Email: GMail, search, dont sort really works.Text Editor: TextMate, you have to buy it, but its worth every penny. There are rumours that its been converting (recovering) Emacs users (addicts). Unfortunately, its Mac only. An alternative is jedit (GPL, Java).DevelopmentBuild system: cmake, throw the autotools away.Source code control system: ditch CVS for subversion.Project management: Trac tracks everything.Scripting language: Ruby is Japanese pragmatism (and has a poignant guide). Python, you say? Python is too academic and snob:Java IDE: JBuilder is great software and has a free version (IMHO better than Eclipse). Java is not a pain anymore since it gained generics and got opensourced.Mark-up language: HTML is so 2001, why dont you take at look at Markdown? Look at the source of this page.C++ libraries: * QT for GUIs. * GSL for math. * Magick++ for manipulating images. * Cairo for creating PDFs. * Boost for just about everything else.ResearchWriting papers: LaTeXWriting papers & enjoying the process: LyXHandsome figures in your papers: xfig or, better, jfig.The occasional presentation with many graphical content: OpenOffice Impress (using the OOOlatex plugin); the alternative is PowerPoint with the TexPoint plugin.Managing BibTeX: jabref: multi-platform, for all your bibtex needs.IEEExplore and BibTeX: convert citations using BibConverter.Cool websitesBest site in the wwworld: WikipediaMutopia for sheet music; the Gutenberg Project for books; LiberLiber for books in italian.Blogs: BloglinesSharing photos: flickr exposes an API you can use.
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)