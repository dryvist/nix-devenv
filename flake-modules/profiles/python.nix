# Python pre-commit profile.
#
# Composes dev-hygiene with python-specific hooks. Consumer imports once:
#
#   imports = [ inputs.nix-devenv.flakeModules.python ];
#
# Enabled on top of base:
# * ruff        — fast Python linter (flake8-equivalent + many plugins)
# * ruff-format — formatter (drop-in for black)
# * mypy        — static type checker; enable per-repo by adding a
#                 mypy.ini or pyproject.toml [tool.mypy] section
#
# bandit and detect-secrets, used by python-template only in the
# inventory, stay opt-in per-repo to keep the profile fast. Add them
# locally via `pre-commit.settings.hooks.bandit.enable = true;` etc.
{
  dev-hygiene,
}:
{ ... }:
{
  imports = [ dev-hygiene ];

  perSystem = _: {
    pre-commit.settings.hooks = {
      ruff.enable = true;
      ruff-format.enable = true;
      mypy.enable = true;
    };
  };
}
