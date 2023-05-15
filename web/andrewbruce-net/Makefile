.PHONY: all
all: dist/*.html dist/blog/*.html dist/app.css

.PHONY: clean
clean:
	rm -rf dist/
	mkdir dist

dist:
	mkdir -p dist

dist/*.html: dist
	cp src/*.html dist/

dist/blog: dist
	mkdir -p dist/blog

dist/blog/*.html: dist/blog
	cp src/blog/*.html dist/blog/

dist/app.css:
	tailwindcss \
		--input src/input.css \
		--output $@ \
		--content src/index.html,src/contact.html,src/cv.html \
		--minify
