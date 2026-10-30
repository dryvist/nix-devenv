{
  description = "Skill orchestration: LangGraph, LlamaIndex, embeddings";

  inputs = {
    # Channel pinned once in channels/flake.nix; see channels/flake.nix.
    channels.url = "github:dryvist/nix-devenv?ref=v0&dir=channels";
    nixpkgs.follows = "channels/nixpkgs";
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, devenv, ... }@inputs:
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
            pkgs = nixpkgs.legacyPackages.${system};
          }
        );
    in
    {
      devShells = forAllSystems (
        { pkgs }:
        {
          default = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [ ./default.nix ];
          };
        }
      );
    };
}
