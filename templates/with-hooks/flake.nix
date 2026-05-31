# with-hooks template — dev environment + org-wide pre-commit hooks
#
# Usage:
#   nix flake init -t github:JacobPEvans/nix-devenv#with-hooks
#   direnv allow              # picks up the devShell
#   pre-commit install        # done by git-hooks.nix shellHook automatically
#
# Picks ONE profile from nix-devenv's flakeModules. Profiles available:
#
#   base       — file hygiene + markdownlint + zizmor (default)
#   nix        — alias for base; covers deadnix/statix via file-glob
#   markdown   — alias for base
#   terraform  — base + terraform-format/validate + tflint
#   ansible    — base + ansible-lint + yamllint (canonical configs from dryvist/.github)
#   python     — base + ruff + ruff-format + mypy
#
# Swap `base` below for the matching profile, then `direnv reload`.
{
  description = "Development environment with org-wide pre-commit hooks";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-devenv = {
      url = "github:dryvist/nix-devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, nix-devenv, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];

      imports = [ nix-devenv.flakeModules.base ];

      perSystem =
        { pkgs, ... }:
        {
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              git
              pre-commit
            ];
          };
        };
    };
}
