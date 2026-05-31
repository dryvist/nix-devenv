# Ansible pre-commit profile.
#
# Composes dev-hygiene with ansible-specific hooks. Consumer imports once:
#
#   imports = [ inputs.nix-devenv.flakeModules.ansible ];
#
# Enabled on top of base:
# * ansible-lint — full ansible-lint pass; reads .ansible-lint from the
#                  worktree (or repo will fetch the canonical one from
#                  dryvist/.github/precommit/configs/ once Phase 1b lands)
# * yamllint     — YAML structure/style check; reads .yamllint or
#                  .yamllint.yml from the worktree
#
# Both linters expect a config file in the consumer repo today. After
# Phase 1b lands the canonical configs in dryvist/.github, this profile
# will be extended to pass `--config <nix-store-path>` automatically and
# the per-repo files can be deleted.
{
  dev-hygiene,
}:
{ ... }:
{
  imports = [ dev-hygiene ];

  perSystem = _: {
    pre-commit.settings.hooks = {
      ansible-lint.enable = true;
      yamllint.enable = true;
    };
  };
}
