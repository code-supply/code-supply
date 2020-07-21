apply: manifest.yaml
	kubectl apply -f manifest.yaml

diff: manifest.yaml
	kubectl diff -f manifest.yaml

manifest.yaml: \
	k8s/affable/stateful-set.yaml \
	k8s/affable/kustomization.yaml
	kustomize build k8s/affable > $@

.PHONY: triggers
triggers:
	gcloud beta builds triggers create cloud-source-repositories \
		--description=affable \
		--repo=mono \
		--tag-pattern="affable-.*" \
		--build-config=web/affable/cloudbuild.yaml

.PHONY: build_vm
build_vm:
	cd packer && packer build ./gce-image.json
.PHONY: provision_vm
provision_vm:
	cd packer && ansible-playbook -i inventory playbook.yaml
