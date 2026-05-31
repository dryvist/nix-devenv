# Smoke-test consumer for nix-devenv's flakeModules.terraform profile.
# Validation: `cd tests/profile-modules/terraform && nix flake check`.
# Catches drift in git-hooks.nix hook names (terraform-format,
# terraform-validate, tflint) before any consumer repo migrates.
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-devenv.url = "path:../../..";
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
      imports = [ nix-devenv.flakeModules.terraform ];
    };
}
