# nix-devenv

Centralized, reusable development shells for the Nix ecosystem — pick a
pre-built environment (Terraform, Ansible, Kubernetes, Python/AI, …) or scaffold
your own, without pulling a heavy dependency tree into your project's lock.

[![OSV Scan][osv-badge]][osv-url]
[![Release Please][release-badge]][release-url]

[osv-badge]: https://github.com/dryvist/nix-devenv/actions/workflows/osv-scan.yml/badge.svg
[osv-url]: https://github.com/dryvist/nix-devenv/actions/workflows/osv-scan.yml
[release-badge]: https://github.com/dryvist/nix-devenv/actions/workflows/release-please.yml/badge.svg
[release-url]: https://github.com/dryvist/nix-devenv/actions/workflows/release-please.yml

This repo owns reusable dev-shell definitions and isolates the heavy transitive
dependency tree of `devenv` (~26 nodes: crate2nix, cachix, git-hooks, …) behind
per-shell locks, so a consumer that only needs a lightweight `mkShell` never
pays for it.

## Installation

Prerequisites:

- [Nix](https://nixos.org/) with flakes enabled (the Determinate Nix installer
  turns them on by default).
- Optional: [`direnv`](https://direnv.net/) for automatic per-project activation.

No install step of its own — consume a shell directly by flake reference:

```bash
# Enter the Terraform shell with its own minimal lock (~2 nodes: just nixpkgs)
nix develop github:dryvist/nix-devenv?dir=shells/tofu
```

The `?dir=<shell>` selector resolves against **that shell's** `flake.lock`, so
`mkShell` consumers never inherit the `devenv` tree.

## Usage

### Consume a shell

```bash
# A: Direct use with an isolated lock (preferred)
nix develop github:dryvist/nix-devenv?dir=shells/tofu

# B: Pin it in a project's .envrc — direnv activates the remote shell
echo 'use flake github:dryvist/nix-devenv?dir=shells/orchestrator --impure' \
  > .envrc

# C: Root flake (convenience) — larger root lock, fine for one-offs
nix develop github:dryvist/nix-devenv#tofu

# E: Scaffold a new repo's dev environment from a template
nix flake init -t github:dryvist/nix-devenv#mkshell    # lightweight mkShell
nix flake init -t github:dryvist/nix-devenv#devenv     # full devenv
nix flake init -t github:dryvist/nix-devenv#with-hooks # dev shell with pre-commit hooks
```

### Compose modules into your own shell (Pattern D)

Importing this repo as a flake input adds its tree to **your** lock — only repos
that choose to import pay for it:

```nix
inputs.nix-devenv.url = "github:dryvist/nix-devenv";
inputs.nix-devenv.inputs.nixpkgs.follows = "nixpkgs";

outputs = { nix-devenv, nixpkgs, ... }: {
  devShells.x86_64-linux.default =
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    nix-devenv.lib.mkEnv {
      inherit pkgs;
      modules = [
        nix-devenv.devenvModules.python-ai
        { packages = [ pkgs.jq ]; }
      ];
    };
};
```

### Available shells

`mkShell` (infrastructure — package lists, minimal lock):

| Shell | Tooling |
| --- | --- |
| `ansible` | ansible, ansible-lint, molecule, sops, age |
| `tofu` | terraform, opentofu, tflint, tfsec, trivy; local checks for Terrakube workspaces |
| `kubernetes` | kubectl, helm, helmfile, kustomize, k9s, kubeconform, kind |
| `containers` | docker, buildkit, crane, skopeo |
| `typescript` | nodejs 22 LTS, pnpm, typescript, ts-language-server, biome |
| `splunk-dev` | Python 3.9 via uv (EOL exception) |
| `aws` | awscli2, aws-vault |
| `azure` | azure-cli |
| `windows` | powershell (pwsh 7) for Windows automation and `.ps1` |
| `server-admin` | IPMI/SoL, VNC, serial, PXE, ISO/firmware, net + disk diag |
| `server-admin-linux` | extends `server-admin`; adds nvme-cli, ethtool, tftp |

`devenv` (Python/AI — declarative services and language modules):

| Shell | Tooling |
| --- | --- |
| `ai-dev` | LangChain, LangGraph, OpenTelemetry (pip venv) |
| `orchestrator` | LangGraph orchestration (uv + pyproject.toml) |
| `mlx-server` | MLX inference (aarch64-darwin only, uv) |

### Reusable modules

| Module | Description |
| --- | --- |
| `devenvModules.python-ai` | Python + LangChain + OTel (venv) |
| `devenvModules.python-ml` | Python + uv sync |

## Architecture

### mkShell vs devenv

| Use `mkShell` when | Use `devenv` when |
| --- | --- |
| The shell is just a package list | You need declarative services |
| It runs in CI where deps must be minimal | You need language tooling (uv) |
| No background processes | You need process management |
| Infrastructure / CLI tooling | A full-stack app or AI/ML project |

Rule: infrastructure shells stay `mkShell`. Convert to `devenv` only when you
actually need services, processes, or language modules.

### Per-shell lock isolation

Each shell carries its own `flake.nix` and `flake.lock` under its subdirectory.
Consumers select a shell's lock with Nix's `?dir=` parameter, so a `mkShell`
consumer resolves a ~2-node lock while a `devenv` consumer resolves the full
~28-node tree. The contract this repo exposes is stable: **a flake reference per
shell, each with an isolated lock** — importers that only want a lightweight
shell never inherit the `devenv` dependency tree.

## Credentials in a dev shell

Shells here ship tooling, never credentials. The contract is the same in every
consuming repo, and it is deliberately dynamic — nothing long-lived is stored
on disk or baked into a shell.

**Never export a secret from `.envrc`.** direnv caches its resolved environment
to disk, so anything minted at `.envrc` load time is persisted there. Mint at
call time instead, in the shell that needs it.

The three patterns, in order of preference:

1. **Let the tool resolve it itself.** `git` needs no token — a credential
   helper answers each request with a freshly minted, short-lived credential.
   `aws` does the same through `credential_process`. Nothing to wire per shell.
2. **A command that prints exports, eval'd on demand.** See
   `shells/tofu/default.nix`, which puts `export-terrakube-env` on `PATH`: it
   logs in, reads the values, and prints `export` lines. The shell does not run
   it — the caller does, when needed:

   ```bash
   eval "$(export-terrakube-env)"
   ```

   A binary that *prints* exports composes with any shell and leaves no trace
   if never called. A `shellHook` that exports is no safer than `.envrc` —
   direnv captures its output during evaluation and persists it to the same
   on-disk cache.
3. **A helper function for tools that only read the environment.** `gh` reads
   `GITHUB_TOKEN` and has no credential-helper hook, so the host shell provides
   `gh-read` (read scope) and `gh-claim` (per-repo write lease, released when
   the shell exits). Both infer the target from the `origin` remote and mint per
   call.

Bootstrap credentials (vault address, role ids) are ambient — injected by the
secrets manager into the environment the shell inherits — so no shell definition
here contains one.

## Adding a shell

1. Create `shells/<name>/default.nix` with the shell definition.
2. Create `shells/<name>/flake.nix` — `mkShell` needs only `nixpkgs`; `devenv`
   needs `nixpkgs` + `devenv`.
3. Create `shells/<name>/.envrc` — `use flake` for `mkShell`,
   `use flake --impure` for `devenv`.
4. Add the shell to the root `flake.nix` `devShells` output.
5. Generate the lock: `cd shells/<name> && nix flake lock`.
6. Test: `cd shells/<name> && nix develop`.

## Updating locks

```bash
# A single shell's lock
cd shells/tofu && nix flake update

# Root lock (affects root-flake consumers)
nix flake update

# Every shell lock
for dir in shells/*/; do (cd "$dir" && nix flake update); done
```

## Validation

```bash
nix flake check    # validate the root flake
nix fmt            # fix formatting (nixfmt-tree)
```

## Cachix binary cache

`devenv` shells benefit from the Cachix binary cache. Add to your Nix config:

```nix
nix.settings = {
  substituters = [ "https://devenv.cachix.org" ];
  trusted-public-keys = [ "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=" ];
};
```

## Contributing

Workspace conventions (commits, branches, signing, PRs) live at
[docs.jacobpevans.com/conventions](https://docs.jacobpevans.com/conventions/overview).

## License

MIT.

---

> Part of a [larger ecosystem of ~40 repos](https://docs.jacobpevans.com) — see how it all fits together.
