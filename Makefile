.POSIX:
affable_version = k8s/affable/version.yaml

k8s/manifest.yaml: \
	k8s/kustomization.yaml \
	k8s/ingress.yaml \
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

operators/tls-lb-operator/VERSION:
	git rev-parse --short HEAD > $@

operators/tls-lb-operator/VERSION_BUILT: operators/tls-lb-operator/VERSION
	docker build -t eu.gcr.io/code-supply/tls-lb-operator:$$(cat $<) operators/tls-lb-operator
	cp $< $@

operators/tls-lb-operator/VERSION_PUSHED: operators/tls-lb-operator/VERSION_BUILT
	docker push eu.gcr.io/code-supply/tls-lb-operator:$$(cat $<)
	cp $< $@

k8s/tls-lb-operator/version.yaml: operators/tls-lb-operator/VERSION_PUSHED
	cd k8s/tls-lb-operator && \
		kustomize edit set image tls-lb-operator=eu.gcr.io/code-supply/tls-lb-operator:$$(cat ../../$<)
	> $@
	echo "apiVersion: apps/v1" >> $@
	echo "kind: Deployment" >> $@
	echo "metadata:" >> $@
	echo "  name: tls-lb-operator" >> $@
	echo "spec:" >> $@
	echo "  template:" >> $@
	echo "    metadata:" >> $@
	echo "      labels:" >> $@
	echo "        version: \"$$(cat $<)\"" >> $@

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

.PHONY: kubectl_set_contexts
kubectl_set_contexts:
	kubectl config set-context \
		affable \
		--cluster=gke_code-supply_europe-west1-b_pink \
		--user=gke_code-supply_europe-west1-b_pink \
		--namespace=affable
