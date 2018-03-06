#!/usr/bin/env make

TEX_OPTS := \
	-halt-on-error \
	-interaction nonstopmode \
	-output-directory _build

all: clean texdeps compile render

compile: compile.kts src/main.tex.vm src/*.csv
	kscript compile.kts

render: compile src/main.tex
	mkdir -p _build
	pdflatex $(TEX_OPTS) src/main.tex

texdeps:
	find . -name *.tex \
		| xargs -n 1 cat \
		| sed -n 's~^[^%%]*\\usepackage[^{]*{\([^}]*\)}.*$$~\1~p' \
		| while read file; do tlmgr install $${file}; done

clean:
	rm -rf _build

