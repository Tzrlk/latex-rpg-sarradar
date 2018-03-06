#!/bin/sh

bin_kscript=`which kscript 2>/dev/null`
bin_pdflatex=`which pdflatex 2>/dev/null`
bin_tlmgr=`which tlmgr 2>/dev/null`

WORK=`pwd`

if [ -z "${bin_kscript}" ] || [ -z "${bin_pdflatex}" ]; then
	echo >&2 "Missing needed binaries."
	exit 1
fi

# Compile the velocity templates
${bin_kscript} compile.kts || {
	echo >&2 "Template compilation failed."
	exit 1
}

# Make sure the build output directory exists
mkdir -p _build

find . -name *.tex \
	| xargs -n 1 cat \
	| sed -n 's~^[^%]*\\usepackage[^{]*{\([^}]*\)}.*$~\1~p' \
	| while read file; do ${bin_tlmgr} install ${file}; done

tex_opts="-halt-on-error"
tex_opts="${tex_opts} -interaction nonstopmode"
tex_opts="${tex_opts} -output-directory _build"

# Compile the latex to pdf
${bin_pdflatex} ${tex_opts} src/main.tex || {
	echo >&2 "LaTeX compilation failed."
	exit 1
}

