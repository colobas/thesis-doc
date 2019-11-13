# ---------------------------------------------------------
# type "make" command in Unix to create the PDF file 
# ---------------------------------------------------------

# Main filename
FILE=esannV2

# ---------------------------------------------------------

all:
	pdflatex  ${FILE}
	biber ${FILE}
	pdflatex  ${FILE}
	pdflatex  ${FILE}

clean:
	(rm -rf *.acr *.acn *.alg *.aux *.bbl *.blg *.glg *.glo *.gls *.ilg *.ist *.lof *.log *.lot *.nlo *.nls *.out *.toc *.xml *.bcf)

veryclean:
	make clean
	rm -f *~ *.*%
	rm -f $(FILE).pdf $(FILE).ps

