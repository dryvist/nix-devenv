# Pre-commit wiring for the repo dev shell: the shared Nix hook set from
# lib/pre-commit-hooks.nix, run through git-hooks.nix. git-hooks.nix exports
# no lib for x86_64-darwin, so the wiring is empty there.
{
  inputs,
  system,
  pkgs,
}:
if inputs.git-hooks.lib ? ${system} then
  inputs.git-hooks.lib.${system}.run {
    src = ../.;
    hooks = import ./pre-commit-hooks.nix { inherit pkgs; };
  }
else
  {
    shellHook = "";
    enabledPackages = [ ];
  }
