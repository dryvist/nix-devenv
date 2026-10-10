# mkShell template — lightweight dev environment with org-wide pre-commit hooks
#
# Usage:
#   nix flake init -t github:JacobPEvans/nix-devenv#mkshell
#   nix develop
{
  description = "Development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-devenv = {
      url = "github:dryvist/nix-devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
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
          devShells.default = pkgs.mkShell {
            inputsFrom = [ config.pre-commit.devShell ];
            buildInputs = with pkgs; [
              # Add your packages here
              git
              jq
            ];

            shellHook = ''
              if [ -z "''${DIRENV_IN_ENVRC:-}" ]; then
                echo "Development environment ready"
              fi
            '';
          };
        };
    };
}
