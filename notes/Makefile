.PHONY: clean clean-all

source := .
output := .
sources := $(wildcard $(source)/*.tex)
objects := $(patsubst %.tex,%.pdf,$(subst $(source),$(output),$(sources)))

all: clean-all $(objects) clean

%.pdf: %.tex
	pdflatex $< > /dev/null
	bibtex8 $(basename $<) || true
	pdflatex $< > /dev/null
	pdflatex $< > /dev/null

clean:
	rm -f *.out *.aux *.log *.bbl *.blg

clean-all:
	rm -f *.out *.aux *.log *.bbl *.blg *.pdf

