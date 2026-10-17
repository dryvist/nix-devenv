# Smoke-test consumer for nix-devenv's flakeModules.ansible profile.
# Validation: `cd tests/profile-modules/ansible && nix flake check`.
# Catches drift in git-hooks.nix hook names and the shared commit-msg hook.
{
  inputs = {
    channels.url = "path:../../../channels";
    nixpkgs.follows = "channels/nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-devenv.url = "path:../../..";
    tofu-github.follows = "nix-devenv/tofu-github";
  };

  outputs =
    inputs@{
      flake-parts,
      nix-devenv,
      tofu-github,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      imports = [ nix-devenv.flakeModules.ansible ];

      perSystem =
        { config, pkgs, ... }:
        let
          hook = config.pre-commit.settings.hooks.conventional-commit-subject;
          pattern = pkgs.lib.removeSuffix "\n" (
            pkgs.lib.fileContents "${tofu-github}/config/commit-message-pattern.txt"
          );
        in
        {
          checks.conventional-commit-subject-contract =
            assert hook.enable;
            assert hook.entry == "${pkgs.gitlint}/bin/gitlint";
            assert hook.stages == [ "commit-msg" ];
            assert
              hook.args == [
                "--ignore"
                "T1,T2,T3,T4,T5,T6,T8,B1,B2,B3,B4,B5,B6,B7,B8"
                "-c"
                "title-match-regex.regex=${pattern}"
                "--msg-filename"
              ];
            # git-hooks.nix installs one git hook per stage that an enabled hook uses.
            assert builtins.elem "commit-msg" config.pre-commit.settings.installStages;
            pkgs.runCommand "conventional-commit-subject-contract" { } "touch $out";
        };
    };
}
