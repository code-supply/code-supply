{ writeShellApplication
, hostingDockerImage
, docker
}:
writeShellApplication {
  name = "hosting-docker-push";
  runtimeInputs = [ docker ];
  text =
    if hostingDockerImage.imageTag == "dirty"
    then ''echo "Commit first!"; exit 1''
    else ''
      docker load < ${hostingDockerImage}
      docker push ${with hostingDockerImage; "${imageName}:${imageTag}"}
    '';
}
