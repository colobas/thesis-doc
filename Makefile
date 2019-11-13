all:
	pandoc -t beamer presentation.md -o presentation.tex --template ./colobas.beamer
	xelatex presentation
	biber presentation
	xelatex presentation
	xelatex presentation

clean:
	(rm -rf *.snm *.bcf *.nav *.xml *.acr *.acn *.alg *.aux *.bbl *.blg *.glg *.glo *.gls *.ilg *.ist *.lof *.log *.lot *.nlo *.nls *.out *.toc)
