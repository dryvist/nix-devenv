# Ansible pre-commit profile.
#
# Composes dev-hygiene with ansible-specific hooks. Consumer imports once:
#
#   imports = [ inputs.nix-devenv.flakeModules.ansible ];
#
# Enabled on top of base:
# * ansible-lint — full ansible-lint pass; reads canonical config from
#                  dryvist/.github via sharedConfigs.ansible-lint
# * yamllint     — YAML structure/style check; reads canonical config from
#                  dryvist/.github via sharedConfigs.yamllint
#
# Consumer repos can delete their per-repo `.ansible-lint` and
# `.yamllint.yml` because both hooks point at the canonical configs in
# the nix store via the `dryvist-github` flake input.
{
  dev-hygiene,
  sharedConfigs,
}:
{ ... }:
{
  imports = [ dev-hygiene ];

  perSystem = _: {
    pre-commit.settings.hooks = {
      ansible-lint = {
        enable = true;
        settings.configPath = sharedConfigs.ansible-lint;
      };
      yamllint = {
        enable = true;
        settings.configPath = sharedConfigs.yamllint;
      };
    };
  };
}
