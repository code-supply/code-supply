manifest.yaml:
	kustomize build k8s > $@

apply: manifest.yaml
	kubectl apply -f manifest.yaml

diff: manifest.yaml
	kubectl diff -f manifest.yaml

.PHONY: set_image_affable
set_image_affable:
	cd k8s/affable && \
		kustomize edit set image "affable=eu.gcr.io/code-supply/affable:$$(git rev-parse --short HEAD)"

.PHONY: install_olm
install_olm:
	kubectl apply -f https://github.com/operator-framework/operator-lifecycle-manager/releases/download/0.15.1/crds.yaml
	kubectl apply -f https://github.com/operator-framework/operator-lifecycle-manager/releases/download/0.15.1/olm.yaml

.PHONY: list_triggers
list_triggers:
	gcloud beta builds triggers list

.PHONY: triggers
triggers:
	gcloud beta builds triggers create cloud-source-repositories \
		--description=affable \
		--repo=mono \
		--branch-pattern="^master$$" \
		--build-config=web/affable/cloudbuild.yaml

.PHONY: build_vm
build_vm:
	cd packer && packer build ./gce-image.json
.PHONY: provision_vm
provision_vm:
	cd packer && ansible-playbook -i inventory playbook.yaml
