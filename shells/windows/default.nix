# Windows-Adjacent Tooling Shell
#
# PowerShell (pwsh) development environment. Cross-platform PowerShell 7 for
# Windows automation, Azure/Exchange scripting, and running/authoring .ps1
# scripts on macOS and Linux. Replaces the homebrew `powershell@preview` cask
# (migrated to a project-scoped Nix shell so pwsh is no longer always-on).
#
# Named "windows" rather than "powershell" to leave room for future
# Windows-adjacent tooling (e.g. samba client, dotnet) without renaming the
# shell and breaking `?dir=shells/windows` consumers.
{
  pkgs,
  extraPackages ? [ ],
}:
pkgs.mkShell {
  buildInputs =
    with pkgs;
    [
      # === PowerShell ===
      powershell # pwsh — cross-platform PowerShell 7
    ]
    ++ extraPackages;

  shellHook = ''
    if [ -z "''${DIRENV_IN_ENVRC:-}" ]; then
      echo "═══════════════════════════════════════════════════════════════"
      echo "Windows-Adjacent Tooling Environment (PowerShell)"
      echo "═══════════════════════════════════════════════════════════════"
      echo ""
      echo "  - pwsh: $(pwsh --version 2>/dev/null)"
      echo ""
      echo "Getting Started:"
      echo "  pwsh                # start an interactive PowerShell session"
      echo "  pwsh ./script.ps1   # run a script"
      echo ""
    fi
  '';
}
