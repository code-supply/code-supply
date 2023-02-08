.PHONY: all
all: dist/*.html dist/app.css

.PHONY: clean
clean:
	rm -rf dist/
	mkdir dist

dist/*.html:
	mkdir -p dist
	cp src/*.html dist/

dist/app.css:
	tailwindcss \
		--input src/input.css \
		--output $@ \
		--content src/index.html,src/contact.html,src/cv.html \
		--minify
