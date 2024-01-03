{ verb
, writeShellApplication
, kubectl
, manifests
}:
writeShellApplication {
  name = "k8s-${verb}";
  runtimeInputs = [ kubectl ];
  text = "kubectl ${verb} -f ${manifests}";
}
