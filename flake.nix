{
  description = "Reusable dev shells in Nix — Terraform, Ansible, Kubernetes, AI/ML, and more";

  inputs = {
    # Channel pinned once in ./channels; see channels/flake.nix.
    channels.url = "github:dryvist/nix-devenv?ref=v0&dir=channels";
    nixpkgs.follows = "channels/nixpkgs";
    # Per-package escape hatch; see channels/flake.nix. Consumed only where a
    # shell needs a package the stable channel cannot yet supply.
    nixpkgs-unstable.follows = "channels/nixpkgs-unstable";

    homelab-contracts = {
      url = "github:dryvist/homelab-contracts?ref=v5";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
    # Sources the org-wide zizmor.yml policy. JacobPEvans/.github#5 merged,
    # so this tracks the default branch.
    dryvist-github = {
      url = "github:JacobPEvans/.github?ref=v1";
      flake = false;
    };
    tofu-github = {
      url = "github:dryvist/tofu-github?ref=v1.29.0";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      devenv,
      tofu-github,
      ...
    }@inputs:
    let
      devenvRoot = "${./.}";
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      mkPreCommitHooks = { pkgs }: import ./lib/pre-commit-hooks.nix { inherit pkgs tofu-github; };
    in
    {
      # === Pre-built shells ===
      #
      # Convenience re-exports using the root flake.lock.
      # The nixpkgs channel is pinned once in channels/flake.nix; this flake
      # and every shell follow it via channels.url + nixpkgs.follows.
      # For isolated locks, use ?dir= pattern instead:
      #   nix develop github:dryvist/nix-devenv?dir=shells/tofu
      devShells = import ./lib/dev-shells.nix {
        inherit inputs systems devenvRoot;
      };

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
      # nix flake init -t github:dryvist/nix-devenv#mkshell
      # nix flake init -t github:dryvist/nix-devenv#devenv
      # nix flake init -t github:dryvist/nix-devenv#with-hooks
      templates = {
        devenv = {
          path = ./templates/devenv;
          description = "devenv shell with services and language modules";
        };
        mkshell = {
          path = ./templates/mkshell;
          description = "Lightweight mkShell for package-list environments";
        };
        with-hooks = {
          path = ./templates/with-hooks;
          description = "Dev shell wired into org-wide pre-commit profile (flake-parts)";
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
      lib.mkPreCommitHooks = mkPreCommitHooks;

      # === Flake-parts modules ===
      #
      # `dev-hygiene` wires treefmt-nix + git-hooks + zizmor (with the
      # org-wide policy from JacobPEvans/.github) into a flake-parts consumer
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
      # `docs` is the dedicated Markdown/MDX profile: it inherits
      # `hygiene-core` (the universal hook set) directly and skips treefmt,
      # so prettier never reformats hand-authored prose. `dev-hygiene` =
      # `hygiene-core` + treefmt, so every existing consumer is unchanged.
      #
      # All module files are called here with nix-devenv's own inputs so
      # the result is pre-bound. Consumer flakes do not need their own
      # treefmt-nix / git-hooks inputs.
      flakeModules = import ./lib/flake-module-profiles.nix {
        inherit inputs mkPreCommitHooks;
      };

      checks = import ./flake-modules/checks.nix inputs systems;

      # Formatter
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
