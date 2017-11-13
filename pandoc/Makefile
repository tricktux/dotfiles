## Put this Makefile in your project directory---i.e., the directory
## containing the paper you are writing. Assuming you are using the
## rest of the toolchain here, you can use it to create .html, .tex,
## and .pdf output files from
## your markdown file.
## -	Change the paths at the top of the file as needed.
## -	Using `make` without arguments will generate html, tex, and pdf
## 	output files from all of the files with the designated markdown
##	extension. The default is `.md` but you can change this.
## -	You can specify an output format with `make tex`, `make pdf` or
## - 	`make html`.
## -	Doing `make clean` will remove all the .tex, .html, and .pdf files
## 	in your working directory. Make sure you do not have files in these
##	formats that you want to keep!

## Markdown extension (e.g. md, markdown, mdown).
MEXT = md

## All markdown files in the working directory
SRC = $(wildcard *.$(MEXT))

# Any file with ext .bib will be used
BIB = $(wildcard *.bib)

## Location of Pandoc support files.
## Windows
# PREFIX = C:\Users\nikoheikkila\AppData\Roaming\pandoc

## OSX & UNIX
PREFIX = ~/.pandoc

## CSL stylesheet (located in the csl folder of the PREFIX directory).
CSL = apsa

DOCX=$(SRC:.md=.docx)
HTML=$(SRC:.md=.html)
PDF=$(SRC:.md=.pdf)

all:	clean $(DOCX) $(HTML) $(PDF)

html:	clean $(HTML)
docx:	clean $(DOCX)
pdf:	clean $(PDF)

%.html:	%.md
	pandoc -r markdown+simple_tables+table_captions+yaml_metadata_block -w html -S --filter pandoc-citeproc -o $@ $<

%.docx:	%.md
	pandoc -r markdown+simple_tables+table_captions+yaml_metadata_block -w docx -s -S --filter pandoc-citeproc -o $@ $<

%.pdf: %.md
	pandoc -r markdown+simple_tables+table_captions+yaml_metadata_block+smart -w latex -s --filter pandoc-citeproc --template eisvogel -o $@ $<

# pandoc -r markdown+simple_tables+table_captions+yaml_metadata_block -w latex -s -S --filter pandoc-citeproc --bibliography $(BIB) --template eisvogel -o $@ $<

clean:
	rm -f $(DOCX) $(HTML) $(PDF)
