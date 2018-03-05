#!/bin/sh

bin_docker=`which docker 2>/dev/null`
bin_kscript=`which kscript 2>/dev/null`
bin_pdflatex=`which pdflatex 2>/dev/null`

WORK=`pwd`

if [ -z "${bin_kscript}" ] || [ -z "${bin_pdflatex}" ]; then
	echo >&2 "Missing needed binaries."
	exit 1
fi

# Compile the velocity templates
eval "${bin_kscript} compile.kts" || {
	echo >&2 "Template compilation failed."
	exit 1
}

# Make sure the build output directory exists
mkdir -p _build

# Compile the latex to pdf
./build-tex.sh src/main.tex ${bin_pdflatex} || {
	echo >&2 "LaTeX compilation failed."
	exit 1
}

