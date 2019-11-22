pandoc:
	pandoc -t beamer presentation.md -o presentation.tex --template ./colobas.beamer
	pdflatex presentation
	biber presentation
	pdflatex presentation
	pdflatex presentation

all:
	pdflatex presentation
	biber presentation
	pdflatex presentation
	pdflatex presentation

clean:
	(rm -rf *.snm *.bcf *.nav *.xml *.acr *.acn *.alg *.aux *.bbl *.blg *.glg *.glo *.gls *.ilg *.ist *.lof *.log *.lot *.nlo *.nls *.out *.toc)
