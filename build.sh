#!/bin/sh

bin_docker=`which docker 2>/dev/null`
bin_kscript=`which kscript 2>/dev/null`
bin_pdflatex=`which pdflatex 2>/dev/null`

WORK=`pwd`

if [ -z "${bin_kscript}" ] || [ -z "${bin_pdflatex}" ]; then
	
	echo "Missing required tools. Substituting via docker."
	if [ -z "${bin_docker}" ]; then
		echo >&2 "Docker not available."
		exit 1
	fi

	registry=${DOCKER_REGISTRY}
	if [ ! -z "${registry}" ]; then
		registry="${registry}/"
	fi

	cmd_common="docker run -it --rm -v \"${WORK}\"://work -w //work"

	if [ -z "${bin_kscript}" ]; then
		echo "Missing kscript substituted for docker command."
		bin_kscript="${cmd_common} ${registry}tzrlk/kscript"
	fi

	if [ -z "${bin_pdflatex}" ]; then
		echo "Missing pdflatex substituted for docker command."
		bin_pdflatex="${cmd_common} ${registry}schickling/latex"
	fi

fi

# Compile the velocity templates
eval ${bin_kscript} compile.kts

# Check that compilation succeeded.
if [ ${?} ]; then
	echo >&2 "Template compilation failed."
	exit 1
fi

# Make sure the build output directory exists
mkdir -p _build

# Compile the latex to pdf
eval ${bin_pdflatex} \
	-halt-on-error \
	-interaction nonstopmode \
	-output-directory _build \
	src/main.tex

if [ ${?} ]; then
	echo >&2 "LaTeX compilation failed."
	exit 1
fi

