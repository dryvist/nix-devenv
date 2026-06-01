{
  description = "TypeScript development environment with Node.js, pnpm, Biome, and TypeScript LSP";

  inputs = {
    # Channel pinned once in ../../channels; see channels/flake.nix.
    channels.url = "path:../../channels";
    nixpkgs.follows = "channels/nixpkgs";
  };

  outputs =
    { nixpkgs, ... }:
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
