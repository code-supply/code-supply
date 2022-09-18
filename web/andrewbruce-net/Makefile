.PHONY: all
all: dist/index.html dist/app.css

.PHONY: clean
clean:
	rm -rf dist/
	mkdir dist

dist/index.html:
	cp src/index.html $@

dist/app.css:
	tailwind-linux-x64 \
		-i src/input.css \
		-o $@ \
		--content src/index.html
