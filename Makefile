.POSIX:
affable_version = k8s/affable/version.yaml
operator_version = k8s/operators/site-operator-version.yaml

k8s/manifest.yaml: \
	k8s/kustomization.yaml \
	k8s/*/*.yaml \
	k8s/operators/site-operator.yaml \
	k8s/operators/site-operator-version.yaml
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

.PHONY: operator_use_head
operator_use_head:
	git rev-parse --short HEAD > operators/site_operator/VERSION

k8s/operators/site-operator.yaml: \
	operators/site_operator/lib/site_operator/controllers/v1/* \
	operators/site_operator/config/* \
	operators/site_operator/VERSION \
	k8s/operators/env-vars/AFFILIATE_SITE_IMAGE
	cd operators/site_operator && \
		mix compile && \
		mix bonny.gen.manifest \
		--namespace operators \
		--image eu.gcr.io/code-supply/site-operator:$$(cat VERSION) \
		--out - \
		> ../../$@

k8s/operators/site-operator-version.yaml:
	> $(operator_version)
	echo "apiVersion: apps/v1" >> $(operator_version)
	echo "kind: Deployment" >> $(operator_version)
	echo "metadata:" >> $(operator_version)
	echo "  name: site-operator" >> $(operator_version)
	echo "  namespace: operators" >> $(operator_version)
	echo "spec:" >> $(operator_version)
	echo "  template:" >> $(operator_version)
	echo "    metadata:" >> $(operator_version)
	echo "      labels:" >> $(operator_version)
	echo "        version: \"$$(cat operators/site_operator/VERSION)\"" >> $(operator_version)

web/affable/VERSION:
	git diff-index --quiet HEAD --
	git rev-parse --short HEAD > $@

web/affable/VERSION_BUILT: web/affable/VERSION
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
	echo "kind: StatefulSet" >> $@
	echo "metadata:" >> $@
	echo "  name: affable" >> $@
	echo "spec:" >> $@
	echo "  template:" >> $@
	echo "    metadata:" >> $@
	echo "      labels:" >> $@
	echo "        version: \"$$(cat $<)\"" >> $@

.PHONY: affable_rotate_sql_credentials
affable_rotate_sql_credentials:
	bin/rotate-google-service-account-key \
		affable \
		google-credentials \
		key.json \
		sql-shared-affable@code-supply.iam.gserviceaccount.com

web/affiliate/VERSION:
	git diff-index --quiet HEAD --
	git rev-parse --short HEAD > $@

web/affiliate/VERSION_BUILT: web/affiliate/VERSION
	docker build -t eu.gcr.io/code-supply/affiliate:$$(cat $<) web/affiliate
	cat $< > $@

web/affiliate/VERSION_PUSHED: web/affiliate/VERSION_BUILT
	docker push eu.gcr.io/code-supply/affiliate:$$(cat $<)
	cat $< > $@

k8s/operators/env-vars/AFFILIATE_SITE_IMAGE: web/affiliate/VERSION_PUSHED
	docker inspect --format='{{index .RepoDigests 0}}' eu.gcr.io/code-supply/affiliate:$$(cat $<) \
		| tr -d '\n' \
		> k8s/operators/env-vars/AFFILIATE_SITE_IMAGE

.PHONY: triggers
triggers:
	for id in $$(gcloud --format=json beta builds triggers list | jq -r .[].id); \
	do \
		gcloud beta builds triggers delete --quiet "$$id"; \
	done
	gcloud beta builds triggers create cloud-source-repositories \
		--quiet \
		--description=affable \
		--repo=mono \
		--branch-pattern="^master$$" \
		--build-config=web/affable/cloudbuild.yaml
	gcloud beta builds triggers create cloud-source-repositories \
		--quiet \
		--description=site_operator \
		--repo=mono \
		--branch-pattern="^master$$" \
		--build-config=operators/site_operator/cloudbuild.yaml
	gcloud beta builds triggers create cloud-source-repositories \
		--quiet \
		--description=affiliate \
		--repo=mono \
		--branch-pattern="^master$$" \
		--build-config=web/affiliate/cloudbuild.yaml

.PHONY: install_istio_operator
install_istio_operator:
	istioctl operator init

.PHONY: kubectl_set_contexts
kubectl_set_contexts:
	kubectl config set-context \
		affable \
		--cluster=gke_code-supply_europe-west1-b_pink \
		--user=gke_code-supply_europe-west1-b_pink \
		--namespace=affable
	kubectl config set-context \
		istio-system \
		--cluster=gke_code-supply_europe-west1-b_pink \
		--user=gke_code-supply_europe-west1-b_pink \
		--namespace=istio-system

.PHONY: build_vm
build_vm:
	cd packer && packer build ./gce-image.json
.PHONY: provision_vm
provision_vm:
	cd packer && ansible-playbook -i inventory playbook.yaml
