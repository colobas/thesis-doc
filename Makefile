# ---------------------------------------------------------
# type "make" command in Unix to create the PDF file 
# ---------------------------------------------------------

# Main filename
FILE=thesis

# ---------------------------------------------------------

all:
	pdflatex  ${FILE}
	makeglossaries ${FILE}
	bibtex ${FILE}
	pdflatex  ${FILE}
	pdflatex  ${FILE}

clean:
	(rm -rf *.acr *.acn *.alg *.aux *.bbl *.blg *.glg *.glo *.gls *.ilg *.ist *.lof *.log *.lot *.nlo *.nls *.out *.toc)

veryclean:
	make clean
	rm -f *~ *.*%
	rm -f $(FILE).pdf $(FILE).ps

