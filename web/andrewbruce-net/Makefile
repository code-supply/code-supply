.PHONY: all
all: dist/*.html dist/app.css

.PHONY: clean
clean:
	rm -rf dist/
	mkdir dist

dist/*.html:
	cp src/*.html dist/

dist/app.css:
	tailwind-linux-x64 \
		--input src/input.css \
		--output $@ \
		--content src/index.html \
		--minify
