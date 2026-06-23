# Reusable devenv module: Python base development toolchain
#
# Provides Python linters, formatters, and type checkers for Python projects.
# Import this module in project devenv shells to get a consistent Python toolchain.
#
# NOTE: pyright is NOT included here — it stays in nix-home global env so that
# IDEs (Cursor/VSCode) can find it in PATH for background linting without
# requiring a specific devenv to be active. Type-checking for the org standard
# is provided by that global pyright + the `flakeModules.python` pre-commit
# profile, not by this devshell. (mypy was dropped 2026-06 when the org
# standard moved to pyright — nothing here ran it any longer.)
#
# Usage in a consumer devenv.nix:
#   { inputs, pkgs, ... }:
#   {
#     imports = [ inputs.nix-devenv.devenvModules.python-base ];
#     # ... project-specific config
#   }
#
# Or from a flake shell:
#   modules = [ nix-devenv.devenvModules.python-base ];
{ pkgs, ... }:
{
  packages = with pkgs; [
    ruff # Fast Python linter and formatter (replaces flake8, isort, black)
    uv # Fast Python package manager (replaces pip/pipx)
  ];
}
