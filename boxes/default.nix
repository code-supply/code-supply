{ nixpkgs }:

{
  meta = {
    inherit nixpkgs;
    nodeSpecialArgs = {
      unhinged =
        let
          prefix-ipv6 = "2001:8b0:b184:5567";
        in
        {
          inherit prefix-ipv6;
          ipv4 = "192.168.1.182";
          router-ipv4 = "192.168.1.1";
          router-ipv6 = "${prefix-ipv6}::1";
          ipv6 = "${prefix-ipv6}::2";
        };
    };
  };
  unhinged = import ./unhinged/configuration.nix;
}
