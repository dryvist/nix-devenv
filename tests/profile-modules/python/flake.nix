# Smoke-test consumer for nix-devenv's flakeModules.python profile.
# Validation: `cd tests/profile-modules/python && nix flake check`.
# Catches drift in git-hooks.nix hook names (ruff, ruff-format, pyright) plus
# the custom pre-push pytest hook. (No .py files here, so pyright matches
# nothing and pytest is pre-push-gated — the check validates evaluation, not
# hook execution.)
{
  inputs = {
    channels.url = "path:../../../channels";
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
      imports = [ nix-devenv.flakeModules.python ];
    };
}
