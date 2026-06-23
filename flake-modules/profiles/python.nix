# Python pre-commit profile.
#
# Composes dev-hygiene with python-specific hooks. Consumer imports once:
#
#   imports = [ inputs.nix-devenv.flakeModules.python ];
#
# Enabled on top of base:
# * ruff        — fast Python linter (flake8-equivalent + many plugins)
# * ruff-format — formatter (drop-in for black)
# * pyright     — static type checker (org-mandated 2026-06, replaced mypy).
#                 The git-hooks.nix native hook bundles the pyright binary but
#                 NOT your deps; it resolves project imports from the repo's
#                 .venv via pyproject.toml `[tool.pyright] venvPath/venv`
#                 (a known git-hooks.nix gotcha — devenv #1234).
# * pytest      — test runner, gated at the PRE-PUSH stage (matches the non-Nix
#                 template; keeps the commit cycle fast). Runs the project's
#                 .venv/bin/pytest — NOT `uv run` (org policy). pre-push staging
#                 also keeps it out of the `nix flake check` derivation, which
#                 runs `--hook-stage pre-commit`.
#
# ┌──────────────────────────── KEEP IN SYNC ────────────────────────────┐
# │ This profile and dryvist/.github precommit/templates/python.yaml are  │
# │ the SAME hook set in two encodings — change BOTH together (no         │
# │ generator yet). The pyright/pytest *entries* differ by design: the    │
# │ YAML calls .venv/bin/{pyright,pytest}; here pyright is the git-hooks   │
# │ native hook and pytest is a custom local hook.                        │
# │                                                                       │
# │ Hook parity (keep identical across both files):                       │
# │   ruff (Nix) / ruff-check (YAML id) -> commit stage                   │
# │   ruff-format                       -> commit stage                   │
# │   pyright                           -> commit stage                   │
# │   pytest                            -> pre-push stage                 │
# └───────────────────────────────────────────────────────────────────────┘
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
      pyright.enable = true;

      # There is no native `pytest` hook in git-hooks.nix, so wire a custom
      # local hook. pre-push stage keeps pytest OUT of the commit cycle AND out
      # of the `nix flake check` derivation (which runs `--hook-stage pre-commit`).
      pytest = {
        enable = true;
        name = "pytest (from .venv, pre-push only)";
        entry = ".venv/bin/pytest"; # NOT `uv run` (org policy); matches the YAML
        language = "system";
        pass_filenames = false;
        always_run = true;
        stages = [ "pre-push" ];
      };
    };
  };
}
