# Smoke-test consumer for nix-devenv's flakeModules.ansible profile.
# Validation: `cd tests/profile-modules/ansible && nix flake check`.
# Catches drift in git-hooks.nix hook names (ansible-lint, yamllint).
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
      imports = [ nix-devenv.flakeModules.ansible ];
    };
}
