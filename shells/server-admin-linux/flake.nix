{
  description = "Server administration shell — Linux-only extras (extends server-admin)";

  inputs = {
    # Channel pinned once in channels/flake.nix; see channels/flake.nix.
    channels.url = "github:dryvist/nix-devenv?ref=v0&dir=channels";
    nixpkgs.follows = "channels/nixpkgs";
  };

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f {
            pkgs = import nixpkgs { inherit system; };
          }
        );
    in
    {
      devShells = forAllSystems (
        { pkgs }:
        {
          default = import ./default.nix { inherit pkgs; };
        }
      );
    };
}
