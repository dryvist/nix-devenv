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
    # Sources the org-wide zizmor.yml policy. dryvist/.github#5 merged,
    # so this tracks the default branch.
    dryvist-github = {
      url = "github:dryvist/.github";
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
      # Profile modules layer language-specific hooks on top of
      # dev-hygiene. A consumer picks ONE profile import — the profile
      # transitively pulls in the base wiring, so terraform repos get
      # the full base hook set plus terraform_format / terraform_validate
      # / tflint with a single line:
      #
      #   imports = [ inputs.nix-devenv.flakeModules.terraform ];
      #
      # `base`, `nix`, and `markdown` are aliases for dev-hygiene — the
      # base wiring already covers nix lints (deadnix, statix) and
      # markdownlint-cli2 because git-hooks.nix file-glob filtering
      # makes them inert when the matching file type is absent.
      #
      # All module files are called here with nix-devenv's own inputs so
      # the result is pre-bound. Consumer flakes do not need their own
      # treefmt-nix / git-hooks inputs.
      flakeModules =
        let
          dev-hygiene = import ./flake-modules/dev-hygiene.nix {
            inherit (inputs) treefmt-nix git-hooks dryvist-github;
            mkPreCommitHooks = { pkgs }: import ./lib/pre-commit-hooks.nix { inherit pkgs; };
          };
        in
        {
          inherit dev-hygiene;
          base = dev-hygiene;
          nix = dev-hygiene;
          markdown = dev-hygiene;
          terraform = import ./flake-modules/profiles/terraform.nix { inherit dev-hygiene; };
          ansible = import ./flake-modules/profiles/ansible.nix { inherit dev-hygiene; };
          python = import ./flake-modules/profiles/python.nix { inherit dev-hygiene; };
        };

      # Formatter
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
