<xsl:stylesheet
  exclude-result-prefixes="xlink dbk rng tei teix xhtml a edate estr html pantor xd xs xsl"
  extension-element-prefixes="exsl estr edate" 
  version="1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:rng="http://relaxng.org/ns/structure/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:teix="http://www.tei-c.org/ns/Examples"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
  xmlns:edate="http://exslt.org/dates-and-times"
  xmlns:estr="http://exslt.org/strings" xmlns:exsl="http://exslt.org/common"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:pantor="http://www.pantor.com/ns/local"
  xmlns:xd="http://www.pnp-software.com/XSLTdoc"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
<xsl:import href="/usr/share/xml/tei/stylesheet/latex/tei.xsl"/>
<xsl:param name="reencode">false</xsl:param>
<xsl:param name="numberBackHeadings">true</xsl:param>
<xsl:param name="numberFrontHeadings">true</xsl:param>
<xsl:param name="spaceCharacter">\hspace*{1em}</xsl:param>
<xsl:param name="classParameters">11pt,twoside</xsl:param>
<xsl:param name="startNamespace"></xsl:param>
<xsl:param name="tocNumberSuffix">.\ </xsl:param>
<xsl:param name="numberSpacer">\ </xsl:param>

  <xsl:variable name="docClass">book</xsl:variable>
<xsl:template name="latexPreambleHook">
\usepackage{makeidx,askinclude}
\makeindex
\defaultfontfeatures{Scale=MatchLowercase}
%\setromanfont{DejaVu Serif}
%\setsansfont{DejaVu Sans}
\setmonofont{DejaVu Sans Mono}
%\setmonofont[Scale=0.9]{Lucida Sans Typewriter}
%\setsansfont[Scale=0.85]{Lucida Sans}
%\setromanfont{Times New Roman}
\setromanfont{Minion Pro}
%\setmonofont{CourierStd}
\setsansfont{Myriad Pro}
\setlength{\headheight}{14pt}
</xsl:template>


<xsl:template name="latexBegin">
<xsl:text>\makeatletter
\thispagestyle{plain}</xsl:text>
<xsl:if test="not(tei:text/tei:front/tei:titlePage)">
  <xsl:call-template name="printTitleAndLogo"/>
</xsl:if>
<xsl:text>\markright{\@title}%
\markboth{\@title}{\@author}%
\fvset{frame=single,numberblanklines=false,xleftmargin=5mm,xrightmargin=5mm}
\fancyhf{} 
\setlength{\headheight}{14pt}
\fancyhead[LE]{\bfseries\leftmark} 
\fancyhead[RO]{\bfseries\rightmark} 
\fancyfoot[RO]{}
\fancyfoot[CO]{\thepage}
\fancyfoot[LO]{}
\fancyfoot[LE]{}
\fancyfoot[CE]{\thepage}
\fancyfoot[RE]{}
\hypersetup{linkbordercolor=0.75 0.75 0.75,urlbordercolor=0.75 0.75 0.75,bookmarksnumbered=true,letterpaper}
\def\l@section{\@dottedtocline{1}{3em}{2.3em}}
\def\l@subsection{\@dottedtocline{2}{4em}{3.2em}}
\def\l@subsubsection{\@dottedtocline{3}{5em}{4.1em}}
\def\l@paragraph{\@dottedtocline{4}{6em}{6em}}
\def\l@subparagraph{\@dottedtocline{5}{7em}{6em}}
\def\@pnumwidth{3em}
\setcounter{tocdepth}{2}
\def\tableofcontents{
\clearpage
\pdfbookmark[0]{Table of Contents}{TOC}
\hypertarget{TOC}{}
\section*{\contentsname}\@starttoc{toc}}
\fancypagestyle{plain}{\fancyhead{}\renewcommand{\headrulewidth}{0pt}}
\def\chaptermark#1{\markboth {\thechapter. \ #1}{}}
\def\sectionmark#1{\markright { \ifnum \c@secnumdepth >\z@
          \thesection. \ %
        \fi
	#1}}
\def\egxmlcite#1{\raisebox{12pt}[0pt][0pt]{\parbox{.95\textwidth}{\raggedleft #1}}}
\def\oddindex#1{{\bfseries\hyperpage{#1}}}
\def\exampleindex#1{{\itshape\hyperpage{#1}}}
\def\mainexampleindex#1{{\bfseries\itshape\hyperpage{#1}}}
\setlength{\leftmargini}{2\parindent}%
\renewcommand{\@listI}{%
   \setlength{\leftmargin}{\leftmargini}%
   \setlength{\topsep}{\medskipamount}%
   \setlength{\itemsep}{0pt}%
   \setlength{\listparindent}{1em}%
   \setlength{\rightskip}{1em}%
}
\renewcommand\normalsize{\@setfontsize\normalsize{10}{12}%
  \abovedisplayskip 10\p@ plus2\p@ minus5\p@
  \belowdisplayskip \abovedisplayskip
  \abovedisplayshortskip  \z@ plus3\p@
  \belowdisplayshortskip  6\p@ plus3\p@ minus3\p@
  \let\@listi\@listI
}
\renewcommand\small{\@setfontsize\small{9pt}{11pt}%
   \abovedisplayskip 8.5\p@ plus3\p@ minus4\p@
   \belowdisplayskip \abovedisplayskip
   \abovedisplayshortskip \z@ plus2\p@
   \belowdisplayshortskip 4\p@ plus2\p@ minus2\p@
   \def\@listi{\leftmargin\leftmargini
               \topsep 2\p@ plus1\p@ minus1\p@
               \parsep 2\p@ plus\p@ minus\p@
               \itemsep 1pt}
}
\renewcommand\footnotesize{\@setfontsize\footnotesize{8}{9.5}%
  \abovedisplayskip 6\p@ plus2\p@ minus4\p@
  \belowdisplayskip \abovedisplayskip
  \abovedisplayshortskip \z@ plus\p@
  \belowdisplayshortskip 3\p@ plus\p@ minus2\p@
  \def\@listi{\leftmargin\leftmargini
              \topsep 2\p@ plus\p@ minus\p@
              \parsep 2\p@ plus\p@ minus\p@
              \itemsep \parsep}
}
\renewcommand\scriptsize{\@setfontsize\scriptsize{7}{8}}
\renewcommand\tiny{\@setfontsize\tiny{5}{6}}
\renewcommand\large{\@setfontsize\large{12}{14.4}}
\renewcommand\Large{\@setfontsize\Large{14.4}{18}}
\renewcommand\LARGE{\@setfontsize\LARGE{17.28}{22}}
\renewcommand\huge{\@setfontsize\huge{20.74}{25}}
\renewcommand\Huge{\@setfontsize\Huge\@xxvpt{30}}
%\parskip3pt
%\parindent0em
% for refdocs
\renewenvironment{itemize}{%
  \advance\@itemdepth \@ne
  \edef\@itemitem{labelitem\romannumeral\the\@itemdepth}%
  \begin{list}{\csname\@itemitem\endcsname}
  {%
   \setlength{\leftmargin}{\parindent}%
   \setlength{\labelwidth}{.7\parindent}%
   \setlength{\topsep}{2pt}%
   \setlength{\itemsep}{2pt}%
   \setlength{\itemindent}{2pt}%
   \setlength{\parskip}{0pt}%
   \setlength{\parsep}{2pt}%
   \def\makelabel##1{\hfil##1\hfil}}%
  }
  {\end{list}}
\catcode`說=\active \def說{{\fontspec{AR PL ZenKai Uni}\char35498}}
\catcode`説=\active \def説{{\fontspec{Kochi Mincho}\char35500}}
\catcode`人=\active \def人{{\fontspec{Kochi Mincho}\char20154}}
\catcode`⁊=\active \def⁊{{\fontspec{Junicode}\char8266}} 
\catcode`Å=\active \defÅ{{\fontspec{DejaVu Serif}\char8491}} 
\catcode`⁻=\active \def⁻{\textsuperscript{-}}
\catcode` =\active \def {\,}
\fancyhfoffset[LO,LE]{2em}
\renewcommand\section{\@startsection {section}{1}{-2em}%
     {-1.75ex \@plus -0.5ex \@minus -.2ex}%
     {0.5ex \@plus .2ex}%
     {\reset@font\Large\bfseries\sffamily}}
\renewcommand\subsection{\@startsection{subsection}{2}{-2em}%
     {-1.75ex\@plus -0.5ex \@minus- .2ex}%
     {0.5ex \@plus .2ex}%
     {\reset@font\Large\sffamily}}
\makeatother </xsl:text>
<xsl:call-template name="beginDocumentHook"/>
</xsl:template>

<xsl:param name="latexGeometryOptions">twoside,letterpaper,lmargin=1in,rmargin=1in,tmargin=1in,bmargin=1in</xsl:param>

<xsl:template match="tei:byline"/>
<xsl:template match="tei:titlePage/tei:note"/>

<xsl:template match="tei:list">
  <xsl:if test="parent::tei:item">\mbox{}\\[-10pt] </xsl:if>
  <xsl:apply-imports/>
</xsl:template>

<xsl:template name="lineBreak">
  <xsl:param name="id"/>
  <xsl:text>\mbox{}\newline &#10;</xsl:text>
</xsl:template>

<xsl:template name="tableHline"/>

<xsl:template name="makeTable">
  <xsl:variable name="r">
    <xsl:value-of select="@rend"/>
  </xsl:variable>
  <xsl:text>{</xsl:text>
  <xsl:if test="$r='rules'">|</xsl:if>
  <xsl:choose>
    <xsl:when test="@xml:id='tab-conformance'">
      <xsl:text>P{.35\textwidth}llllllll</xsl:text>
    </xsl:when>
    <xsl:when test="@xml:id='tab-content-models'">
      <xsl:text>P{.25\textwidth}P{.15\textwidth}P{.5\textwidth}</xsl:text>
    </xsl:when>
    <xsl:when test="@xml:id='tab-mods'">
      <xsl:text>L{.15\textwidth}P{.4\textwidth}L{.35\textwidth}</xsl:text>
    </xsl:when>
    <xsl:when test="@rend='wovenodd'">
      <xsl:text>L{.15\textwidth}P{.85\textwidth}</xsl:text>
    </xsl:when>
    <xsl:when test="@rend='attList'">
      <xsl:text>L{.15\textwidth}P{.65\textwidth}</xsl:text>
    </xsl:when>
    <xsl:when test="@rend='attDef'">
      <xsl:text>L{.1\textwidth}P{.5\textwidth}</xsl:text>
    </xsl:when>
    <xsl:when test="@rend='valList'">
      <xsl:text>L{.1\textwidth}P{.4\textwidth}</xsl:text>
    </xsl:when>
    <xsl:when test="@preamble">
      <xsl:value-of select="@preamble"/>
    </xsl:when>
    <xsl:when test="function-available('exsl:node-set')">
      <xsl:call-template name="makePreamble-complex">
	<xsl:with-param name="r" select="$r"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="makePreamble-simple">
	<xsl:with-param name="r" select="$r"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:text>}&#10;</xsl:text>
  <xsl:call-template name="tableHline"/>
  <xsl:choose>
    <xsl:when test="tei:head and not(@rend='display')">
      <xsl:if test="not(ancestor::tei:table)">
	<xsl:text>\endfirsthead </xsl:text>
	<xsl:text>\multicolumn{</xsl:text>
	<xsl:value-of select="count(tei:row[1]/tei:cell)"/>
	<xsl:text>}{c}{</xsl:text>
	<xsl:apply-templates mode="ok" select="tei:head"/>
	<xsl:text>(cont.)}\\\hline \endhead </xsl:text>
      </xsl:if>
      <xsl:text>\caption{</xsl:text>
      <xsl:apply-templates mode="ok" select="tei:head"/>
      <xsl:text>}\\ </xsl:text>
    </xsl:when>
    <xsl:otherwise> </xsl:otherwise>
  </xsl:choose>
    <xsl:if test="$r='rules'">\hline </xsl:if>
    <xsl:apply-templates/>
    <xsl:if test="$r='rules'">
      <xsl:text>\\ \hline </xsl:text>
    </xsl:if>
</xsl:template>

<!--
  <xsl:template match="tei:table">
    <xsl:if test="@xml:id">
      <xsl:text>\label{</xsl:text>
      <xsl:value-of   select="@xml:id"/>
      <xsl:text>}</xsl:text>
    </xsl:if>
    <xsl:text> \par</xsl:text>
    <xsl:choose>
      <xsl:when test="@rend='wovenodd' or @rend='attList' or
		      @rend='valList' or @rend='attDef'"> 
	<xsl:text>\begin{small}\begin{tabular}</xsl:text>
	<xsl:call-template name="makeTable"/>
	<xsl:text>\end{tabular}\end{small}\par</xsl:text>
      </xsl:when>
      <xsl:when test="ancestor::tei:table"> 
	<xsl:text>\begin{tabular}</xsl:text>
	<xsl:call-template  name="makeTable"/> 
	<xsl:text>\end{tabular}</xsl:text>
      </xsl:when>
      <xsl:otherwise> 
	<xsl:text>\begin{longtable}</xsl:text>
	<xsl:call-template name="makeTable"/>
	<xsl:text>\end{longtable} \par</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
-->

<!--
<xsl:template match="tei:term">
  <xsl:apply-imports/>
  <xsl:if test="not(@rend='noindex')">
    <xsl:text>\index{</xsl:text>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>}</xsl:text>
  </xsl:if>
</xsl:template>
-->
<xsl:template match="tei:ident">
  <xsl:apply-imports/>
  <xsl:if test="@type">
    <xsl:processing-instruction name="xmltex">
      <xsl:text>\index{</xsl:text>
      <xsl:value-of select="normalize-space(.)"/>
      <xsl:text> (</xsl:text>
      <xsl:value-of select="@type"/>
      <xsl:text>)}</xsl:text>
    </xsl:processing-instruction>
  </xsl:if>
</xsl:template>

<xsl:template match="tei:index"/>

<xsl:template match="tei:index[@indexName='ODDS']">
  <xsl:for-each select="tei:term">
    <xsl:text>\index{</xsl:text>
    <xsl:choose>
      <xsl:when test="@sortBy">
	<xsl:value-of select="@sortBy"/>
	<xsl:text>=</xsl:text>
	<xsl:value-of select="."/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>|oddindex</xsl:text>
    <xsl:text>}</xsl:text>
  </xsl:for-each>
  <xsl:for-each select="tei:index/tei:term">
    <xsl:text>\index{</xsl:text>
    <xsl:choose>
      <xsl:when test="@sortBy">
	<xsl:value-of select="@sortBy"/>
	<xsl:text>=</xsl:text>
	<xsl:value-of select="."/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>!</xsl:text>
    <xsl:value-of select="../../tei:term"/>
    <xsl:text>|oddindex</xsl:text>
    <xsl:text>}</xsl:text>
  </xsl:for-each>

</xsl:template>


<xsl:template name="egXMLEndHook">
  <xsl:if test="@corresp and key('IDS',substring-after(@corresp,'#'))">
    <xsl:text>\egxmlcite{</xsl:text>
    <xsl:for-each select="key('IDS',substring-after(@corresp,'#'))">
      <xsl:text>Source: \cite{</xsl:text>
      <xsl:value-of select="@xml:id"/>
      <xsl:text>}</xsl:text>
    </xsl:for-each>
    <xsl:text>}</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template name="egXMLStartHook">
<xsl:for-each select=".//teix:*">
<xsl:variable name="Me">
<xsl:value-of select="local-name(.)"/>
</xsl:variable>
<xsl:text>\index{</xsl:text>
<xsl:value-of select="$Me"/>
<xsl:text>=</xsl:text>
<xsl:text>&lt;</xsl:text>
<xsl:value-of select="$Me"/>
<xsl:text>&gt;</xsl:text>
<xsl:text>|</xsl:text><xsl:choose>
  <xsl:when test="ancestor::tei:div[@xml:id=$Me]">
    <xsl:text>mainexampleindex</xsl:text>
  </xsl:when>
  <xsl:otherwise>
    <xsl:text>exampleindex</xsl:text>
  </xsl:otherwise>
</xsl:choose>
<xsl:text>}</xsl:text>
<xsl:for-each select="@*">
  <xsl:choose>
    <xsl:when test="starts-with(name(),'xml:')"/>
    <xsl:otherwise>
      <xsl:text>\index{</xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:text>=@</xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:text>!&lt;</xsl:text>
      <xsl:value-of select="$Me"/>
      <xsl:text>&gt;</xsl:text>
      <xsl:text>|exampleindex}</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:for-each>
</xsl:for-each>
</xsl:template>


<xsl:template name="latexEnd">
<xsl:text>\include{Guidelines-index}
</xsl:text>
<exsl:document href="Guidelines-index.tex" method="text" encoding="utf8">
\cleardoublepage
\pdfbookmark[0]{Index}{INDEX}
\hypertarget{INDEX}{}
\printindex
</exsl:document>
</xsl:template>

  <xsl:template name="numberFrontDiv">
    <xsl:param name="minimal"/>
    <xsl:if test="count(ancestor::tei:div)&lt;3">
      <xsl:number count="tei:div" format="i.1.1" level="multiple"/>
      <xsl:if test="$minimal='false'">
	<xsl:value-of select="$numberSpacer"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:div[parent::tei:front| parent::tei:body|parent::tei:back]">
    <xsl:text>\include{Guidelines-</xsl:text>
    <xsl:value-of select="@xml:id"/>
    <xsl:text>}&#10;</xsl:text>
    <exsl:document 
	href="Guidelines-{@xml:id}.tex" 
	method="text" 
	encoding="utf8">
    <xsl:apply-templates/>
    </exsl:document>
  </xsl:template>

  <xsl:template match="tei:divGen[@type='toc']">
    <exsl:document 
	href="Guidelines-toc.tex" 
	method="text" 
	encoding="utf8">
      \tableofcontents
    </exsl:document>
  </xsl:template>

  <xsl:template match="tei:titlePage">
<xsl:text>
\include{Guidelines-titlepage} 
</xsl:text>
    <exsl:document 
	href="Guidelines-titlepage.tex" 
	method="text" 
	encoding="utf8">
  \begin{titlepage}
<xsl:apply-templates/>
  \maketitle
  \end{titlepage}
  \cleardoublepage
    </exsl:document>
  </xsl:template>

</xsl:stylesheet>


