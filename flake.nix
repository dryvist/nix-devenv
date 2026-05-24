{
  description = "Reusable dev shells in Nix — Terraform, Ansible, Kubernetes, AI/ML, and more";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";

    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Inputs consumed by flakeModules.dev-hygiene.
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Pinned to the feat/zizmor-policy branch HEAD until
    # dryvist/.github#5 merges; flip back to the default branch
    # afterward.
    dryvist-github = {
      url = "github:dryvist/.github/feat/zizmor-policy";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      devenv,
      ...
    }@inputs:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      # === Pre-built shells ===
      #
      # Convenience re-exports using the root flake.lock.
      # For isolated locks, use ?dir= pattern instead:
      #   nix develop github:JacobPEvans/nix-devenv?dir=shells/terraform
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          pkgsUnfree = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          # Minimal shell for working on this repo
          default = pkgs.mkShell {
            packages = [
              pkgs.nixfmt-tree
              pkgs.nil
              pkgs.nix-diff
            ];
          };

          # mkShell shells (infrastructure tooling)
          ansible = import ./shells/ansible/default.nix { inherit pkgs; };
          ansible-apps = import ./shells/ansible/default.nix {
            inherit pkgs;
            extraPackages = [ pkgs.doppler ];
            extraPythonPackages = ps: [
              ps.docker
              ps.httplib2
            ];
          };
          terraform = import ./shells/terraform/default.nix { pkgs = pkgsUnfree; };
          kubernetes = import ./shells/kubernetes/default.nix { inherit pkgs; };
          containers = import ./shells/containers/default.nix { inherit pkgs; };
          typescript = import ./shells/typescript/default.nix { inherit pkgs; };
          splunk-dev = import ./shells/splunk-dev/default.nix { inherit pkgs; };
          aws = import ./shells/aws/default.nix { inherit pkgs; };
          azure = import ./shells/azure/default.nix { inherit pkgs; };
          server-admin = import ./shells/server-admin/default.nix { inherit pkgs; };

          # devenv shells (Python/AI development)
          ai-dev = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [ ./shells/ai-dev/default.nix ];
          };
          orchestrator = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [ ./shells/orchestrator/default.nix ];
          };
        }
        // nixpkgs.lib.optionalAttrs (system == "aarch64-darwin") {
          mlx-server = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [ ./shells/mlx-server/default.nix ];
          };
        }
        // nixpkgs.lib.optionalAttrs (system == "x86_64-linux" || system == "aarch64-linux") {
          server-admin-linux = import ./shells/server-admin-linux/default.nix { inherit pkgs; };
        }
      );

      # === Composable devenv modules ===
      #
      # Import these in custom devenv shells for reusable Python stacks:
      #   modules = [ nix-devenv.devenvModules.python-ai ];
      devenvModules = {
        python-base = ./modules/python-base.nix;
        python-ai = ./modules/python-ai.nix;
        python-ml = ./modules/python-ml.nix;
      };

      # === Scaffolding templates ===
      #
      # nix flake init -t github:JacobPEvans/nix-devenv#mkshell
      # nix flake init -t github:JacobPEvans/nix-devenv#devenv
      templates = {
        devenv = {
          path = ./templates/devenv;
          description = "devenv shell with services and language modules";
        };
        mkshell = {
          path = ./templates/mkshell;
          description = "Lightweight mkShell for package-list environments";
        };
      };

      # === Composition helper ===
      #
      # Build custom devenv shells in consumer repos:
      #   devShells.default = nix-devenv.lib.mkEnv {
      #     pkgs = nixpkgs.legacyPackages.${system};
      #     modules = [ nix-devenv.devenvModules.python-ai ./custom.nix ];
      #   };
      lib.mkEnv =
        { pkgs, modules }:
        devenv.lib.mkShell {
          inherit inputs pkgs;
          inherit modules;
        };

      # === Pre-commit hook defaults ===
      #
      # Org-wide hook set for cachix/git-hooks.nix consumers. Returns an
      # attrset suitable for merging into `pre-commit.settings.hooks`:
      #
      #   pre-commit.settings.hooks =
      #     (inputs.nix-devenv.lib.mkPreCommitHooks { inherit pkgs; })
      #     // {
      #       # Per-repo overrides (e.g. treefmt with local wrapper).
      #     };
      lib.mkPreCommitHooks = { pkgs }: import ./lib/pre-commit-hooks.nix { inherit pkgs; };

      # === Flake-parts modules ===
      #
      # `dev-hygiene` wires treefmt-nix + git-hooks + zizmor (with the
      # org-wide policy from dryvist/.github) into a flake-parts consumer
      # in one import. See flake-modules/dev-hygiene.nix for usage.
      #
      # The module file is called here with nix-devenv's own inputs so
      # the resulting flake-parts module is pre-bound. Consumers just do
      # `imports = [ inputs.nix-devenv.flakeModules.dev-hygiene ]` and
      # get the treefmt + git-hooks wiring without needing those flake
      # inputs in their own flake.nix.
      flakeModules = {
        dev-hygiene = import ./flake-modules/dev-hygiene.nix {
          inherit (inputs) treefmt-nix git-hooks dryvist-github;
          mkPreCommitHooks = { pkgs }: import ./lib/pre-commit-hooks.nix { inherit pkgs; };
        };
      };

      # Formatter
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
