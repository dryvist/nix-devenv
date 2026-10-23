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
  inputs.self.devShells.${system}
  // {
    private-identifier-hook = import ../tests/private-identifier-hook.nix {
      inherit pkgs;
      hook = hooks.private-identifiers;
    };
  }
)
