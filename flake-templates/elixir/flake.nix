{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      forAllSystems =
        generate:
        nixpkgs.lib.genAttrs
          [
            "aarch64-darwin"
            "x86_64-darwin"
            "aarch64-linux"
            "x86_64-linux"
          ]
          (
            system:
            generate (
              import nixpkgs {
                inherit system;
                overlays = [
                  (
                    self: super:
                    let
                      beamPackages = with super.beam_minimal; packagesWith interpreters.erlang_27;
                    in
                    {
                      inherit beamPackages;
                      erlang = beamPackages.erlang_27;
                      elixir = beamPackages.elixir_1_17;
                    }
                  )
                ];
              }
            )
          );
    in
    {
      devShells = forAllSystems (
        { pkgs, ... }:
        {
          default = pkgs.callPackage ./shell.nix { };
        }
      );
    };
}
