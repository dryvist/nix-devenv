# Universal pre-commit hygiene — the grandparent module.
#
# Wires together the org-wide hook set that EVERY repo wants, with no
# formatter opinion baked in:
# * git-hooks       — pre-commit hooks from lib.mkPreCommitHooks (file
#                     hygiene, nix lints, markdownlint-cli2, commit subjects)
# * JacobPEvans/.github — zizmor's `unpinned-uses` trusted-publisher policy
#                     pulled in as `--config`, so consumers don't ship
#                     their own .github/zizmor.yml; markdownlint-cli2 also
#                     falls back to the org .markdownlint-cli2.yaml when
#                     the consumer has no markdownlint config of its own
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
{ self, ... }:
let
  # Root-level markdownlint config files that win over the org config. The
  # list mirrors the fallback logic in JacobPEvans/.github's reusable
  # workflow .github/workflows/_markdown-lint.yml, so local hooks and CI
  # lint markdown with the same config.
  markdownlintConfigFiles = [
    ".markdownlint-cli2.jsonc"
    ".markdownlint-cli2.yaml"
    ".markdownlint-cli2.cjs"
    ".markdownlint-cli2.mjs"
    ".markdownlint.jsonc"
    ".markdownlint.json"
    ".markdownlint.yaml"
    ".markdownlint.yml"
    ".markdownlint.cjs"
    ".markdownlint.mjs"
  ];
  # `self` is the consumer flake's source tree. Flake sources contain only
  # git-tracked files, so an untracked config is invisible here.
  hasMarkdownlintConfig = builtins.any (
    file: builtins.pathExists (self + "/${file}")
  ) markdownlintConfigFiles;
in
{
  imports = [
    git-hooks.flakeModule
  ];

  perSystem =
    { pkgs, ... }:
    {
      pre-commit.settings.hooks =
        let
          hooks = mkPreCommitHooks { inherit pkgs; };
        in
        hooks
        // {
          # Append the org-wide zizmor policy from JacobPEvans/.github to the
          # args mkPreCommitHooks already defines (persona / severity /
          # confidence). `//` is a SHALLOW merge, so the zizmor attrset must
          # be merged explicitly — `zizmor.args = […]` alone would replace
          # the whole hook and drop its `enable` / `files`, leaving zizmor
          # inert.
          zizmor = hooks.zizmor // {
            args = [
              "--persona=regular"
              "--min-severity=medium"
              "--min-confidence=medium"
              "--config"
              "${dryvist-github}/zizmor.yml"
            ];
          };

          # Point at the org-wide markdownlint config only when the consumer
          # ships no config of its own; a repo with one keeps using it. Same
          # shallow-merge care as zizmor: setting `args` on the bare attrset
          # would drop the hook's `enable` / `files` / `excludes`.
          markdownlint-cli2 =
            if hasMarkdownlintConfig then
              hooks.markdownlint-cli2
            else
              hooks.markdownlint-cli2
              // {
                args = [
                  "--config"
                  "${dryvist-github}/.markdownlint-cli2.yaml"
                ];
              };
        };
    };
}
