#!/usr/bin/env make

all: clean compile docker_build docker_run

compile: compile.kts src/main.tex.vm src/*.csv
	kscript compile.kts

docker_prep:
	docker pull blang/latex:ctanbasic

docker_build: latex.docker | docker_prep
	docker build \
		--build-arg http_proxy=$${http_proxy} \
		--build-arg https_proxy=$${https_proxy} \
		--build-arg ftp_proxy=$${ftp_proxy} \
		--build-arg no_proxy=$${no_proxy} \
		--file latex.docker \
		--quiet \
		. > latex.img

docker_run: latex.img src/main.tex | docker_build compile
	docker run -it --rm \
		-v $$(pwd):/work \
		$$(cat latex.img) \
		src/main.tex

tex_deps:
	find . -name *.tex \
		| xargs -n 1 cat \
		| sed -n 's~^[^%%]*\\usepackage[^{]*{\([^}]*\)}.*$$~\1~p' \
		| sort -u \
		| uniq

clean:
	rm -rf \
		_build \
		latex.img \
		src/main.tex

