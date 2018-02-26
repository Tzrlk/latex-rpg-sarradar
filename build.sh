#!/bin/sh

if ! which docker 1>/dev/null 2>&1; then
	echo >&2 "Couldn't find docker executable. You need this."
	exit 1
fi

WORK=`pwd`

docker run -it --rm \
	--volume /var/run/docker.sock:/var/run/docker.sock \
	--volume "${HOME}/.rocker_cache":/root/.rocker_cache \
	--volume "${HOME}/.docker":/root/.docker \
	--volume "${WORK}":/work \
	--workdir /work \
	--env     HPWD=/work \
	tzrlk/rocker-compose \
	run

