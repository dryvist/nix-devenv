# devenv template — module-based dev environment with services support
#
# Usage:
#   nix flake init -t github:JacobPEvans/nix-devenv#devenv
#   nix develop --impure
{
  description = "Development environment (devenv)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-devenv = {
      url = "github:dryvist/nix-devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, devenv, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];

      # Org-wide pre-commit hook set. The module wires git-hooks.nix and
      # installs the hooks when the shell is entered.
      imports = [ inputs.nix-devenv.flakeModules.base ];

      perSystem =
        { config, pkgs, ... }:
        {
          devShells.default = devenv.lib.mkShell {
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
                  pre-commit
                ] ++ config.pre-commit.settings.enabledPackages;

                enterShell = ''
                  ${config.pre-commit.shellHook}
                  echo "Development environment ready"
                '';
              }
            ];
          };
        };
    };
}
