# Code Supply Monorepo

Things in here:

- bin/ : scripts for dealing with things Code Supply develops
- k8s/ : Kustomize manifests for Kubernetes
- operators/ : Operators deployed to the affable cluster
- packer/ : VM images - currently a GCP free-tier thing
- terraform/ : Infra config for all clusters, VMs, domain names etc.
- web/ : Websites that I work on
  - affable/ : A work-in-progress point-n-click, non-WYSIWIG website builder
  - affiliate/ : The sites that get deployed by affable
  - andrewbruce-net/ : My homepage written in Idris. It'll hopefully soon be replaced by an affable site
  - code-supply/ : code.supply homepage, which is already replaced by an affable site
  - fixtures/ : Shared JSON transport fixtures between affable and affiliate
