{ verb
, writeShellApplication
, kubectl
, hostingK8sManifests
}:
writeShellApplication {
  name = "hosting-k8s-${verb}";
  runtimeInputs = [ kubectl ];
  text = "kubectl ${verb} -f ${hostingK8sManifests}";
}
