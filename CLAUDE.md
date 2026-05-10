# nix-devenv - AI Agent Instructions

Centralized, reusable development environments for the Nix ecosystem.

## Purpose

This repo owns ALL reusable development shell definitions. It isolates devenv's
heavy transitive dependency tree (~26 nodes: crate2nix, cachix, git-hooks, etc.)
from module-exporting repos (nix-ai, nix-home, nix-darwin).

## Architecture

### Four-Repo Boundary

| Repo | Purpose | Imports nix-devenv? |
|------|---------|-------------------|
| nix-darwin | macOS system config | Never |
| nix-home | User dev environment | Never |
| nix-ai | AI coding tools | Never |
| **nix-devenv** | Development shells | N/A (this repo) |

**Core module repos NEVER import nix-devenv.** They use Pattern A or B (below)
for zero lock impact.

### mkShell vs devenv

| Use mkShell when | Use devenv when |
|-----------------|-----------------|
| Shell is just a package list | Need declarative services (databases, queues) |
| Used in CI where deps must be minimal | Need language-specific tooling (Python venvs, uv) |
| No services or background processes | Need process management |
| Infrastructure/CLI tooling repo | Full-stack app or AI/ML project |

**Rule: Infrastructure shells stay mkShell.** Only convert to devenv when you
actually need services, processes, or language modules.

### Per-Shell Lock Isolation

Each shell has its own `flake.nix` and `flake.lock` in its subdirectory.
Consumers select a specific shell's lock using Nix's `?dir=` parameter:

```bash
# mkShell shell — ~2 node lock (just nixpkgs)
nix develop github:JacobPEvans/nix-devenv?dir=shells/terraform

# devenv shell — ~28 node lock (nixpkgs + devenv tree)
nix develop github:JacobPEvans/nix-devenv?dir=shells/ai-dev
```

This means mkShell consumers never pay for devenv's dependency tree.

## Consumer Patterns

### Pattern A — Direct use with isolated lock (preferred)

```bash
nix develop github:JacobPEvans/nix-devenv?dir=shells/terraform
```

Each shell resolves against its OWN flake.lock. No bloat leakage.

### Pattern B — .envrc in a project repo

```bash
# .envrc
use flake github:JacobPEvans/nix-devenv?dir=shells/orchestrator --impure
```

direnv activates the remote shell with its own lock. No local flake.nix needed.

### Pattern C — Root flake (convenience)

```bash
nix develop github:JacobPEvans/nix-devenv#terraform
```

Uses the root flake.lock (larger — carries devenv). Fine for quick one-off use.

### Pattern D — Local flake.nix with composition

```nix
inputs.nix-devenv.url = "github:JacobPEvans/nix-devenv";
inputs.nix-devenv.inputs.nixpkgs.follows = "nixpkgs";

outputs = { nix-devenv, nixpkgs, ... }: {
  devShells.default = nix-devenv.lib.mkEnv {
    pkgs = nixpkgs.legacyPackages.${system};
    modules = [
      nix-devenv.devenvModules.python-ai
      { packages = [ pkgs.jq ]; }
    ];
  };
};
```

Consumer's flake.lock gains nix-devenv's tree — only repos that CHOOSE to import pay.

### Pattern E — Template scaffolding

```bash
nix flake init -t github:JacobPEvans/nix-devenv#devenv
nix flake init -t github:JacobPEvans/nix-devenv#mkshell
```

## Available Shells

### mkShell (infrastructure)

| Shell | Description |
|-------|-------------|
| ansible | Ansible, ansible-lint, molecule, sops, age |
| terraform | Terraform, terragrunt, opentofu, tflint, tfsec, trivy (composes aws shell) |
| kubernetes | kubectl, helm, helmfile, kustomize, k9s, kubeconform, kind |
| containers | docker, buildkit, crane, skopeo |
| typescript | nodejs 22 LTS, pnpm, typescript, typescript-language-server, biome (formatter/linter/LSP) |
| splunk-dev | Python 3.9 via uv (EOL exception) |
| aws | awscli2, aws-vault |
| azure | azure-cli |
| server-admin | ipmitool, freeipmi, tigervnc, picocom, minicom, tio, dnsmasq, xorriso, cabextract, nmap, smartmontools |
| server-admin-linux | extends server-admin; adds nvme-cli, hdparm, sg3_utils, ethtool, tftp-hpa, atftp (Linux only) |

### devenv (Python/AI)

| Shell | Description |
|-------|-------------|
| ai-dev | LangChain, LangGraph, OpenTelemetry (pip venv) |
| orchestrator | LangGraph orchestration (uv + pyproject.toml) |
| mlx-server | MLX inference (aarch64-darwin only, uv) |

## Reusable Modules

| Module | Description |
|--------|-------------|
| `devenvModules.python-ai` | Python + LangChain + OTel (venv) |
| `devenvModules.python-ml` | Python + uv sync |

## How to Add a New Shell

1. Create `shells/<name>/default.nix` with the shell definition
2. Create `shells/<name>/flake.nix` — mkShell needs only nixpkgs; devenv needs nixpkgs + devenv
3. Create `shells/<name>/.envrc` — `use flake` for mkShell, `use flake --impure` for devenv
4. Add the shell to the root `flake.nix` devShells output
5. Generate the lock: `cd shells/<name> && nix flake lock`
6. Test: `cd shells/<name> && nix develop`

## How to Update Locks

```bash
# Update a single shell's lock
cd shells/terraform && nix flake update

# Update root lock (affects Pattern C consumers)
nix flake update

# Update all shell locks
for dir in shells/*/; do (cd "$dir" && nix flake update); done
```

## Build Validation

```bash
nix flake check    # Validates root flake
nix fmt            # Fix formatting (nixfmt-tree)
```

## Cachix Binary Cache

devenv shells benefit from the Cachix binary cache. Add to your nix config:

```nix
nix.settings = {
  substituters = [ "https://devenv.cachix.org" ];
  trusted-public-keys = [ "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=" ];
};
```

## Part of the Nix Ecosystem

| Repo | Purpose |
|------|---------|
| [nix-darwin](https://github.com/JacobPEvans/nix-darwin) | macOS system config |
| [nix-home](https://github.com/JacobPEvans/nix-home) | User dev environment |
| [nix-ai](https://github.com/JacobPEvans/nix-ai) | AI coding tools |
| **nix-devenv** (this repo) | Development shells |
