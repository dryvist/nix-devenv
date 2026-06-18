# Universal pre-commit hygiene — the grandparent module.
#
# Wires together the org-wide hook set that EVERY repo wants, with no
# formatter opinion baked in:
# * git-hooks       — pre-commit hooks from lib.mkPreCommitHooks (file
#                     hygiene, nix lints, markdownlint-cli2)
# * dryvist/.github — zizmor's `unpinned-uses` trusted-publisher policy
#                     pulled in as `--config`, so consumers don't ship
#                     their own .github/zizmor.yml
#
# Deliberately does NOT pull in treefmt-nix. Formatting is an opinion that
# differs by repo type — prettier reformatting hand-authored Markdown/MDX
# prose is undesirable for docs repos. `dev-hygiene` layers treefmt on top
# of this for the repos that want it; the `docs` profile inherits this core
# directly and skips treefmt.
#
# Like dev-hygiene, this file is a function that nix-devenv's flake.nix
# calls eagerly with its own inputs, returning a pre-bound flake-parts
# module — `inputs.<thing>` references resolve against nix-devenv's inputs,
# not the consumer's.
{
  git-hooks,
  dryvist-github,
  mkPreCommitHooks,
}:
{ ... }:
{
  imports = [
    git-hooks.flakeModule
  ];

  perSystem =
    { pkgs, ... }:
    {
      pre-commit.settings.hooks = (mkPreCommitHooks { inherit pkgs; }) // {
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
