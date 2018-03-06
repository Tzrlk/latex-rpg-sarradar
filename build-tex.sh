#!/bin/sh

input=${1}
command=${2}
if [ -z "${command}" ]; then
	command=pdflatex
fi

# This script should run inside the pdflatex environment.

tlmgr update --self
find . -name *.tex \
	| xargs -n 1 cat \
	| sed -n 's~^[^%]*\\usepackage[^{]*{\([^}]*\)}.*$~\1~p' \
	| while read file; do tlmgr install ${file}; done

tex_opts="-halt-on-error"
tex_opts="${tex_opts} -interaction nonstopmode"
tex_opts="${tex_opts} -output-directory _build"

eval "${command} ${tex_opts} ${input}"

