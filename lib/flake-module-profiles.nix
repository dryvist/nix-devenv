{ inputs, mkPreCommitHooks }:
let
  hygiene-core = import ../flake-modules/hygiene-core.nix {
    inherit (inputs) git-hooks dryvist-github;
    inherit mkPreCommitHooks;
  };
  dev-hygiene = import ../flake-modules/dev-hygiene.nix {
    inherit (inputs) treefmt-nix;
    inherit hygiene-core;
  };
  # Materializes nix-store paths to the canonical lint configs in
  # JacobPEvans/.github at precommit/configs/. terraform and ansible
  # profiles consume this so consumer repos can delete their
  # per-repo .tflint.hcl / .ansible-lint / .yamllint.yml copies.
  sharedConfigs = import ./fetch-shared-configs.nix {
    inherit (inputs) dryvist-github;
  };
in
{
  inherit dev-hygiene hygiene-core;
  base = dev-hygiene;
  nix = dev-hygiene;
  markdown = dev-hygiene;
  docs = import ../flake-modules/profiles/docs.nix { inherit hygiene-core; };
  terraform = import ../flake-modules/profiles/terraform.nix {
    inherit dev-hygiene sharedConfigs;
  };
  ansible = import ../flake-modules/profiles/ansible.nix {
    inherit dev-hygiene sharedConfigs;
  };
  python = import ../flake-modules/profiles/python.nix { inherit dev-hygiene; };
}
