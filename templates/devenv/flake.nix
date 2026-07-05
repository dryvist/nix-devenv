# devenv template — module-based dev environment with services support
#
# Usage:
#   nix flake init -t github:JacobPEvans/nix-devenv#devenv
#   nix develop --impure
{
  description = "Development environment (devenv)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
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
            modules = [
              {
                devenv.root =
                  let
                    pwd = builtins.getEnv "PWD";
                  in
                  if pwd != "" then pwd else builtins.toString ./.;

                # Add your configuration here
                packages = with pkgs; [
                  git
                  jq
                ];

                enterShell = ''
                  echo "Development environment ready"
                '';
              }
            ];
          };
        }
      );
    };
}
