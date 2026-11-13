inputs: systems:
let
  forAllSystems = inputs.nixpkgs.lib.genAttrs systems;
in
forAllSystems (
  system:
  let
    pkgs = inputs.nixpkgs.legacyPackages.${system};
    ansibleShell = import ../shells/ansible/default.nix { inherit pkgs; };
    hooks = import ../lib/pre-commit-hooks.nix {
      inherit pkgs;
      inherit (inputs) tofu-github;
    };
  in
  inputs.self.devShells.${system}
  // {
    ansible-collections-path-hook = import ../tests/ansible-collections-path.nix {
      inherit pkgs;
      inherit (ansibleShell) shellHook;
    };
    private-identifier-hook = import ../tests/private-identifier-hook.nix {
      inherit pkgs;
      hook = hooks.private-identifiers;
    };
  }
)
