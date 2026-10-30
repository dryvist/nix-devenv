# nix-devenv - AI Agent Instructions

Centralized, reusable development environments for the Nix ecosystem.

## Purpose

This repo owns ALL reusable development shell definitions. It isolates devenv's
larger transitive dependency tree
from module-exporting repos (nix-ai, nix-home, nix-darwin).

## Architecture

### Four-Repo Boundary

| Repo | Purpose | Imports nix-devenv? |
| ------ | --------- | ------------------- |
| nix-darwin | macOS system config | Never |
| nix-home | User dev environment | Never |
| nix-ai | AI coding tools | Never |
| **nix-devenv** | Development shells | N/A (this repo) |

**Core module repos NEVER import nix-devenv.** They use Pattern A or B for zero
lock impact; see the [consumer guide](docs/using-shells.md#consumer-patterns).

### mkShell vs devenv

**Rule: Infrastructure shells stay mkShell.** Only convert to devenv when you
actually need services, processes, or language modules.

### Per-Shell Lock Isolation

Each shell has its own `flake.nix` and `flake.lock` in its subdirectory.
Consumers select a specific shell's lock using Nix's `?dir=` parameter. This
means mkShell consumers never pay for devenv's dependency tree.

Consumer patterns, shell catalog, module exports, and Cachix setup are in the
[consumer guide](docs/using-shells.md). The [README](README.md) has the quick
start.

## How to Add a New Shell

1. Create `shells/<name>/default.nix` with the shell definition
2. Create `shells/<name>/flake.nix` — mkShell needs only nixpkgs; devenv needs nixpkgs + devenv
3. Create `shells/<name>/.envrc` — `use flake` for mkShell, `use flake --impure` for devenv
4. Add the shell to `lib/dev-shells.nix`; the root flake exports that set
5. Generate the lock: `cd shells/<name> && nix flake lock`
6. Test: `cd shells/<name> && nix develop`

## How to Update Locks

```bash
# Update a single shell's lock
cd shells/tofu && nix flake update

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

## References

See the [README](README.md) for project scope and the [consumer guide](docs/using-shells.md)
for shell selection and composition.
