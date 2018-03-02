#!/bin/sh

if ! which docker 1>/dev/null 2>&1; then
	echo >&2 "Couldn't find docker executable. You need this."
	exit 1
fi

WORK=`pwd`

# Compile the velocity templates
docker run -it --rm \
	--volume  "${WORK}":/work \
	--workdir /work \
	--entrypoint /root/.sdkman/candidates/kscript/current/bin/kscript \
	tzrlk/kscript \
		compile.kts

# Check that compilation succeeded.
if [ ${?} ]; then
	echo >&2 "Template compilation failed."
	exit 1
fi

# Make sure the build output directory exists
mkdir -p _build

# Compile the latex to pdf
docker run -it --rm \
	--volume  "${WORK}":/work \
	--workdir /work \
	schickling/latex \
		-halt-on-error \
		-interaction nonstopmode \
		-output-directory _build \
		src/main.tex

if [ ${?} ]; then
	echo >&2 "LaTeX compilation failed."
	exit 1
fi

