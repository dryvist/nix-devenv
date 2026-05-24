# Org-wide dev-hygiene flake-parts module.
#
# Wires together:
# * treefmt-nix     — formatter set (nixfmt, deadnix, statix, prettier,
#                     shfmt, taplo) with the org's standard options
# * git-hooks       — pre-commit hooks from lib.mkPreCommitHooks plus
#                     treefmt configured against the local wrapper
# * dryvist/.github — zizmor's `unpinned-uses` trusted-publisher policy
#                     pulled in as `--config`, so consumers don't ship
#                     their own .github/zizmor.yml
#
# Consumer:
#   {
#     inputs.nix-devenv.url = "github:JacobPEvans/nix-devenv";
#     outputs = inputs@{ flake-parts, ... }:
#       flake-parts.lib.mkFlake { inherit inputs; } {
#         imports = [ inputs.nix-devenv.flakeModules.dev-hygiene ];
#         # ... per-system / Claude-specific config ...
#       };
#   }
#
# That's it: no `inputs.treefmt-nix`, no `inputs.git-hooks`, no local
# treefmt.nix, no .github/zizmor.yml in consumers.
#
# The file is a function that nix-devenv's flake.nix calls eagerly with
# its own inputs, returning a flake-parts module. That way the consumer
# imports a pre-bound module — `inputs.<thing>` references inside this
# file resolve against nix-devenv's inputs, not the consumer's.
{
  treefmt-nix,
  git-hooks,
  dryvist-github,
  mkPreCommitHooks,
}:
{ ... }:
{
  imports = [
    treefmt-nix.flakeModule
    git-hooks.flakeModule
  ];

  perSystem =
    {
      config,
      pkgs,
      ...
    }:
    {
      treefmt = {
        projectRootFile = "flake.nix";
        programs = {
          nixfmt.enable = true;
          deadnix.enable = true;
          statix.enable = true;
          prettier.enable = true;
          shfmt.enable = true;
          taplo.enable = true;
        };
        settings.formatter.prettier.options = [
          "--print-width"
          "100"
        ];
        settings.formatter.shfmt.options = [
          "--indent"
          "2"
        ];
      };

      pre-commit.settings.hooks = (mkPreCommitHooks { inherit pkgs; }) // {
        treefmt = {
          enable = true;
          package = config.treefmt.build.wrapper;
        };
        # Override the args list to pull the org-wide zizmor policy
        # from dryvist/.github. mkPreCommitHooks defines persona /
        # severity / confidence; --config is appended here.
        zizmor.args = [
          "--persona=regular"
          "--min-severity=medium"
          "--min-confidence=medium"
          "--config"
          "${dryvist-github}/zizmor.yml"
        ];
      };
    };
}
