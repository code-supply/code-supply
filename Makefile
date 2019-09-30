.PHONY: build
build:
	cd packer && packer build ./gce-image.json
