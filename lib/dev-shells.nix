{
  inputs,
  systems,
  devenvRoot,
}:
let
  inherit (inputs)
    nixpkgs
    nixpkgs-unstable
    homelab-contracts
    devenv
    ;
  forAllSystems = nixpkgs.lib.genAttrs systems;
in
forAllSystems (
  system:
  let
    pkgs = nixpkgs.legacyPackages.${system};
    pkgsUnfree = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    pkgsUnstableUnfree = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    flowLock = homelab-contracts.packages.${system}.flow-lock;
    preCommit = import ./pre-commit-shell.nix { inherit inputs system pkgs; };
  in
  {
    # Minimal shell for working on this repo; installs the pre-commit hooks on entry
    default = pkgs.mkShell {
      inherit (preCommit) shellHook;
      packages = [
        pkgs.nixfmt-tree
        pkgs.nil
        pkgs.nix-diff
        pkgs.pre-commit
      ]
      ++ preCommit.enabledPackages;
    };

    # mkShell shells (infrastructure tooling)
    ansible = import ../shells/ansible/default.nix { inherit pkgs; };
    ansible-apps = import ../shells/ansible/default.nix {
      inherit pkgs;
      extraPackages = [
        flowLock
        pkgs.doppler
        # Vendor-neutral S3 client. Playbooks that publish or fetch
        # artifacts shell out to it, so without it declared here every
        # object-storage task exits 2 and reads as a store outage rather
        # than a missing tool — the same failure shape the hvac note in
        # shells/ansible/default.nix describes. It currently resolves
        # only by leaking in from the system profile, which is the same
        # fragility in a slower form.
        pkgs.awscli2
        ((pkgs.openbao.override { withUi = false; }).overrideAttrs (
          finalAttrs: _previousAttrs: {
            version = "2.5.5";
            src = pkgs.fetchFromGitHub {
              owner = "openbao";
              repo = "openbao";
              tag = "v${finalAttrs.version}";
              hash = "sha256-75Rm9EGkvUKJ05d55bboPAE+Nm/GLLgH1TqDrExkJO0=";
            };
            vendorHash = "sha256-3d3g6f0O7X+aedYCfLbqLNuITKNQuxZkApWTTKSk7lA=";
          }
        ))
      ];
      extraPythonPackages = ps: [
        ps.docker
        ps.httplib2
        ps.hvac # community.hashi_vault
        ps.netutils # networktocode.nautobot gql_inventory plugin
        (ps.proxmoxer.overridePythonAttrs (_: {
          # The pinned nixpkgs revision labels pre-2.3 source as 2.3.0.
          src = pkgs.fetchFromGitHub {
            owner = "proxmoxer";
            repo = "proxmoxer";
            rev = "99fe9814d6212c614a944ce7b3d907e05042c4fa";
            hash = "sha256-v/QqNCzkcYk2pqr9tTeyvEEeXt4nzqooHAQEIiJitZ4=";
          };
        }))
      ];
    };
    kubernetes = import ../shells/kubernetes/default.nix { inherit pkgs; };
    containers = import ../shells/containers/default.nix { inherit pkgs; };
    typescript = import ../shells/typescript/default.nix { inherit pkgs; };
    splunk-dev = import ../shells/splunk-dev/default.nix { inherit pkgs; };
    aws = import ../shells/aws/default.nix { inherit pkgs; };
    azure = import ../shells/azure/default.nix { inherit pkgs; };
    database = import ../shells/database/default.nix { inherit pkgs; };
    windows = import ../shells/windows/default.nix { inherit pkgs; };
    server-admin = import ../shells/server-admin/default.nix { inherit pkgs; };

  }
  // nixpkgs.lib.optionalAttrs (builtins.elem system nixpkgs-unstable.lib.systems.flakeExposed) {
    # Keep the root and isolated shell on the same OpenTofu version.
    tofu = import ../shells/tofu/default.nix {
      pkgs = pkgsUnfree;
      pkgsUnstable = pkgsUnstableUnfree;
      extraPackages = [ flowLock ];
    };
  }
  // nixpkgs.lib.optionalAttrs (builtins.hasAttr system devenv.packages) {
    # devenv shells (Python/AI development)
    ai-dev = devenv.lib.mkShell {
      inherit inputs pkgs;
      modules = [
        ../shells/ai-dev/default.nix
        { devenv.root = pkgs.lib.mkForce devenvRoot; }
      ];
    };
    orchestrator = devenv.lib.mkShell {
      inherit inputs pkgs;
      modules = [
        ../shells/orchestrator/default.nix
        { devenv.root = pkgs.lib.mkForce (devenvRoot + "/shells/orchestrator"); }
      ];
    };
  }
  // nixpkgs.lib.optionalAttrs (system == "aarch64-darwin") {
    mlx-server = devenv.lib.mkShell {
      inherit inputs pkgs;
      modules = [
        ../shells/mlx-server/default.nix
        { devenv.root = pkgs.lib.mkForce (devenvRoot + "/shells/mlx-server"); }
      ];
    };
  }
  // nixpkgs.lib.optionalAttrs (system == "x86_64-linux" || system == "aarch64-linux") {
    server-admin-linux = import ../shells/server-admin-linux/default.nix { inherit pkgs; };
  }
)
