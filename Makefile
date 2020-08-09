.POSIX:
affable_version = k8s/affable/version.yaml

all: \
	k8s/manifest.yaml \
	operators/site_operator/manifest.yaml

k8s/manifest.yaml: \
	k8s/kustomization.yaml \
	k8s/*/*.yaml
	kustomize build k8s > $@

apply: \
	k8s/manifest.yaml \
	operators/site_operator/manifest.yaml
	kubectl apply \
		-f operators/site_operator/manifest.yaml \
		-f k8s/manifest.yaml

diff: \
	k8s/manifest.yaml \
	operators/site_operator/manifest.yaml
	kubectl diff \
		-f operators/site_operator/manifest.yaml \
		-f k8s/manifest.yaml

.PHONY:
operator_use_head:
	git rev-parse --short HEAD > operators/site_operator/VERSION

operators/site_operator/manifest.yaml: \
	operators/site_operator/VERSION \
	operators/site_operator/lib/**/* \
	operators/site_operator/config/*
	cd operators/site_operator && \
		mix compile && \
		yes | mix bonny.gen.manifest \
		--namespace operators \
		--image eu.gcr.io/code-supply/site-operator:$$(cat VERSION) && \
		echo

.PHONY:
affable_use_head:
	cd k8s/affable && \
		kustomize edit set image "affable=eu.gcr.io/code-supply/affable:$$(git rev-parse --short HEAD)"
	> $(affable_version)
	echo "apiVersion: apps/v1" >> $(affable_version)
	echo "kind: StatefulSet" >> $(affable_version)
	echo "metadata:" >> $(affable_version)
	echo "  name: affable" >> $(affable_version)
	echo "spec:" >> $(affable_version)
	echo "  template:" >> $(affable_version)
	echo "    metadata:" >> $(affable_version)
	echo "      labels:" >> $(affable_version)
	echo "        version: \"$$(git rev-parse --short HEAD)\"" >> $(affable_version)

.PHONY: affable_rotate_sql_credentials
affable_rotate_sql_credentials:
	bin/rotate-google-service-account-key \
		affable \
		google-credentials \
		key.json \
		sql-shared-affable@code-supply.iam.gserviceaccount.com

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
	gcloud beta builds triggers create cloud-source-repositories \
		--description=site_operator \
		--repo=mono \
		--branch-pattern="^master$$" \
		--build-config=operators/site_operator/cloudbuild.yaml

.PHONY: install_istio
install_istio:
	istioctl install \
		--set values.kiali.enabled=true \
		--set values.grafana.enabled=true \
		--set values.tracing.enabled=true \
		--set meshConfig.outboundTrafficPolicy.mode=REGISTRY_ONLY \
		--set values.gateways.istio-egressgateway.enabled=true


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
