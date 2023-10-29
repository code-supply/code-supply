{ writeShellApplication
, docker
, image
}:
writeShellApplication {
  name = "docker-push";
  runtimeInputs = [ docker ];
  text =
    if image.imageTag == "dirty"
    then ''echo "Commit first!"; exit 1''
    else ''
      docker load < ${image}
      docker push ${with image; "${imageName}:${imageTag}"}
    '';
}
