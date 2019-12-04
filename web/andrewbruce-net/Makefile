.POSIX:
.SUFFIXES:

public/cv.pdf: bin/server
	bin/generate-cv-pdf $@
public/key.asc:
	gpg \
		--export \
		--armor \
		F6F6E949990C4DD41E79D22C2D501B260861257F \
		> $@
bin/server: bin src/*.idr .packages
	touch public/cv.pdf
	idris \
		--codegen node \
		--package mrk \
		--package webserver \
		--sourcepath src \
		--idrispath src \
		--output $@ \
		src/Main.idr
clean:
	rm -rf \
		bin/server \
		src/*.ibc \
		.packages
.packages: vendor
	cd vendor/mrk && idris --install mrk.ipkg
	cd vendor/idris-web-server && idris --install webserver.ipkg
	touch .packages
