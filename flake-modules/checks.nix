inputs: systems:
let
  forAllSystems = inputs.nixpkgs.lib.genAttrs systems;
in
forAllSystems (
  system:
  let
    pkgs = inputs.nixpkgs.legacyPackages.${system};
    hooks = import ../lib/pre-commit-hooks.nix {
      inherit pkgs;
      inherit (inputs) tofu-github;
    };
  in
  assert
    builtins.hasAttr "tofu" inputs.self.devShells.${system}
    == builtins.elem system inputs.nixpkgs-unstable.lib.systems.flakeExposed;
  assert
    builtins.hasAttr "ai-dev" inputs.self.devShells.${system}
    == builtins.hasAttr system inputs.devenv.packages;
  assert
    builtins.hasAttr "orchestrator" inputs.self.devShells.${system}
    == builtins.hasAttr system inputs.devenv.packages;
  inputs.self.devShells.${system}
  // {
    private-identifier-hook = import ../tests/private-identifier-hook.nix {
      inherit pkgs;
      hook = hooks.private-identifiers;
    };
  }
)
