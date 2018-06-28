---
title:	    big_table_template.md
subtitle:   Document Description
author:		Reinaldo Molina
email:      reinaldo.molinaperez at honeywell dot com
date:       Tue Jun 26 2018 15:30
header-includes: |
  \usepackage[table]{xcolor}
  \usepackage{longtable,booktabs,typearea}
caption-justification: centering
---

\newcommand{\hl}{\textbf}
\newcommand*{\ind}{\hspace*{0.5cm}}

\storeareas\normalsetting
\KOMAoption{paper}{landscape}
\areaset{2.5\textwidth}{0.7\textheight}
\recalctypearea

\thispagestyle{plain}

\begin{longtable}{ p{5cm} c c c c p{2cm} p{10cm} }
\hline
\large{\hl{Name}} & \large{\hl{Completed}} & \large{\hl{Duration}} & \large{\hl{Start}} & \large{\hl{Finish}} & \large{\hl{Engineer}} & \large{\hl{Comment/Status}} \\
\hline

Test Equipment Software& 0 & 344 days & 5/2/2018 & 8/26/2019 & - & - \\

\ind Pre-Development Activities& \cellcolor{red} 0 &104 days&5/2/2018&9/24/2018& - & - \\

\rowcolor{green}\ind\ind Project Setup \& Tracking & 100 & 3 days & 5/2/2018 & 5/4/2018 & Gerald &
	[5-10-18]: Completed some really really long example.\newline
	Tue Jun 26 2018 15:49: Another update \\

\hline

\end{longtable}
\clearpage
\normalsetting
