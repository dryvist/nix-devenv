{
  description = "MLX inference server (Apple Silicon only)";

  inputs = {
    # Channel pinned once in ../../channels; see channels/flake.nix.
    channels.url = "path:../../channels";
    nixpkgs.follows = "channels/nixpkgs";
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, devenv, ... }@inputs:
    let
      # MLX only ships aarch64 wheels — restrict to Apple Silicon
      systems = [ "aarch64-darwin" ];
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
