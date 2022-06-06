.POSIX:
affable_version = k8s/affable/version.yaml

k8s/manifest.yaml: \
	k8s/kustomization.yaml \
	k8s/*/*.yaml
	kustomize build k8s > $@

.PHONY: apply
apply: \
	k8s/manifest.yaml
	kubectl \
		--context=affable \
		apply \
		-f k8s/manifest.yaml

diff: \
	k8s/manifest.yaml
	kubectl diff \
		-f k8s/manifest.yaml

web/affable/VERSION:
	git rev-parse --short HEAD > $@

web/affable/VERSION_BUILT: web/affable/VERSION
	cd web/affable; mix dialyzer
	cd web/affable; ./tests
	docker build -t eu.gcr.io/code-supply/affable:$$(cat $<) web/affable
	cat $< > $@

web/affable/VERSION_PUSHED: web/affable/VERSION_BUILT
	docker push eu.gcr.io/code-supply/affable:$$(cat $<)
	cat $< > $@

k8s/affable/version.yaml: web/affable/VERSION_PUSHED
	cd k8s/affable && \
		kustomize edit set image affable=eu.gcr.io/code-supply/affable:$$(cat ../../$<)
	> $@
	echo "apiVersion: apps/v1" >> $@
	echo "kind: Deployment" >> $@
	echo "metadata:" >> $@
	echo "  name: affable" >> $@
	echo "spec:" >> $@
	echo "  template:" >> $@
	echo "    metadata:" >> $@
	echo "      labels:" >> $@
	echo "        version: \"$$(cat $<)\"" >> $@

web/affiliate/VERSION:
	git rev-parse --short HEAD > $@

web/affiliate/VERSION_BUILT: web/affiliate/VERSION
	cd web/affiliate; mix test
	docker build -t eu.gcr.io/code-supply/affiliate:$$(cat $<) web/affiliate
	cat $< > $@

web/affiliate/VERSION_PUSHED: web/affiliate/VERSION_BUILT
	docker push eu.gcr.io/code-supply/affiliate:$$(cat $<)
	cat $< > $@

.PHONY: kubectl_set_contexts
kubectl_set_contexts:
	kubectl config set-context \
		affable \
		--cluster=gke_code-supply_europe-west1-b_pink \
		--user=gke_code-supply_europe-west1-b_pink \
		--namespace=affable

.PHONY: build_vm
build_vm:
	cd packer && packer build ./gce-image.json
.PHONY: provision_vm
provision_vm:
	cd packer && ansible-playbook -i inventory playbook.yaml
