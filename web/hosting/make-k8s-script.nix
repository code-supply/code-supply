{ verb
, writeShellApplication
, kubectl
, hostingK8sManifests
}:
writeShellApplication {
  name = "hosting-k8s-${verb}";
  runtimeInputs = [
    kubectl
    hostingK8sManifests
  ];
  text = "kubectl ${verb} -f ${hostingK8sManifests}";
}
