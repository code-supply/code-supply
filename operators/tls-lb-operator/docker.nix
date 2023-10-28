{ dockerTools
, buildEnv
, busybox
, tlsLbOperator
, version
}:

let
  shellOperatorImage = dockerTools.pullImage {
    imageName = "flant/shell-operator";
    imageDigest = "sha256:d1fe58aec7d9b5ddbbc619831274dd634c7e6c8a4ed3e8ac06291521372d1b51";
    sha256 = "sha256-f/4CEJ48FfDBxB/os76CHcLonC3JlrTbVW/RO1u0vB8=";
  };
in
dockerTools.buildImage {
  name = "codesupplydocker/tls-lb-operator";
  tag = version;
  fromImage = shellOperatorImage;

  config = {
    Entrypoint = [ "/sbin/tini" "--" "/shell-operator" ];
    Cmd = [ "start" ];
    Env = [ "LC_ALL=C.UTF-8" "RELEASE_COOKIE=unused" ];
  };

  copyToRoot = buildEnv {
    name = "image-root";
    paths = [
      tlsLbOperator
      busybox
    ];
    pathsToLink = [ "/bin" "/hooks" ];
  };
}
