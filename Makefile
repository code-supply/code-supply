.POSIX:

k8s/manifest.yaml: \
	k8s/kustomization.yaml \
	k8s/*/*.yaml
	kustomize build k8s > $@

.PHONY: apply
apply: \
	k8s/manifest.yaml
	kubectl \
		--context=unhinged \
		apply \
		-f k8s/manifest.yaml

diff: \
	k8s/manifest.yaml
	kubectl diff \
		-f k8s/manifest.yaml

operators/tls-lb-operator/VERSION:
	git rev-parse --short HEAD > $@

operators/tls-lb-operator/VERSION_BUILT: operators/tls-lb-operator/VERSION
	cd operators/tls-lb-operator/; mix dialyzer
	cd operators/tls-lb-operator/; mix test
	docker build -t codesupplydocker/tls-lb-operator:$$(cat $<) operators/tls-lb-operator
	cp $< $@

operators/tls-lb-operator/VERSION_PUSHED: operators/tls-lb-operator/VERSION_BUILT
	docker push codesupplydocker/tls-lb-operator:$$(cat $<)
	cp $< $@

k8s/tls-lb-operator/version.yaml: operators/tls-lb-operator/VERSION_PUSHED
	cd k8s/tls-lb-operator && \
		kustomize edit set image tls-lb-operator=codesupplydocker/tls-lb-operator:$$(cat ../../$<)
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

