.PHONY: build
build:
	cd packer && packer build ./gce-image.json
provision:
	cd packer && ansible-playbook -i inventory playbook.yaml
