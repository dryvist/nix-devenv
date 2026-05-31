# Pure helper that returns nix-store paths to the canonical lint configs
# in dryvist/.github at `precommit/configs/`. Consumed by profile flake
# modules so terraform / ansible / python repos can delete their per-repo
# copies of `.tflint.hcl`, `.ansible-lint`, `.yamllint.yml`.
#
# Version pinning: paths are derived from the `dryvist-github` flake
# input, so `flake.lock` controls which revision of the configs every
# consumer pulls. One `nix flake update` in nix-devenv → every consumer
# repo gets the latest configs on the next `direnv reload`.
#
# Schema of consumer side:
#   pre-commit.settings.hooks.tflint.args =
#     [ "--config" sharedConfigs.tflint ];
#   pre-commit.settings.hooks.ansible-lint.settings.configPath =
#     sharedConfigs.ansible-lint;
#   pre-commit.settings.hooks.yamllint.settings.configPath =
#     sharedConfigs.yamllint;
{ dryvist-github }:
{
  tflint = "${dryvist-github}/precommit/configs/tflint.hcl";
  ansible-lint = "${dryvist-github}/precommit/configs/ansible-lint.yml";
  yamllint = "${dryvist-github}/precommit/configs/yamllint.yml";
}
