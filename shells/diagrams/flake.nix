{
  description = "Diagrams-as-code development environment with D2, draw.io, and Python";

  inputs = {
    # Channel pinned once in channels/flake.nix; see channels/flake.nix.
    channels.url = "github:dryvist/nix-devenv?ref=v0&dir=channels";
    nixpkgs.follows = "channels/nixpkgs";
    # Only d2 and drawio are taken from here — see default.nix for why.
    nixpkgs-unstable.follows = "channels/nixpkgs-unstable";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      ...
    }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f {
            pkgs = import nixpkgs { inherit system; };
            pkgsUnstable = import nixpkgs-unstable { inherit system; };
          }
        );
    in
    {
      devShells = forAllSystems (
        { pkgs, pkgsUnstable }:
        {
          default = import ./default.nix { inherit pkgs pkgsUnstable; };
        }
      );
    };
}
