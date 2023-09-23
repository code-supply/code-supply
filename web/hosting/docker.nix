{ dockerTools
, version
, buildEnv
, hosting
, busybox
}:
dockerTools.buildImage
{
  name = "codesupplydocker/hosting";
  tag = version;
  config = {
    Cmd = [ "server" ];
    Env = [ "LC_ALL=C.UTF-8" ];
  };
  copyToRoot = buildEnv {
    name = "image-root";
    paths = [
      hosting
      busybox
    ];
    pathsToLink = [ "/bin" ];
  };
}
