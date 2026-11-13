# Smoke-test consumer for nix-devenv's flakeModules.terraform profile.
# Validation: `cd tests/profile-modules/terraform && nix flake check`.
# Catches drift in git-hooks.nix hook names (terraform-format,
# terraform-validate, tflint) and the shared gitleaks hook before any
# consumer repo migrates.
{
  inputs = {
    channels.url = "github:dryvist/nix-devenv?ref=v0&dir=channels";
    nixpkgs.follows = "channels/nixpkgs";
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

      perSystem =
        { config, pkgs, ... }:
        let
          hook = config.pre-commit.settings.hooks.gitleaks;
        in
        {
          checks.gitleaks-contract =
            assert hook.enable;
            assert !hook.pass_filenames;
            assert hook.entry == "${pkgs.gitleaks}/bin/gitleaks";
            assert builtins.head hook.args == "git";
            assert builtins.elem "--pre-commit" hook.args;
            assert builtins.elem "--staged" hook.args;
            assert builtins.elem "--redact" hook.args;
            pkgs.runCommand "gitleaks-contract" { } "touch $out";
        };
    };
}
