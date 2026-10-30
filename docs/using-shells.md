# Using nix-devenv shells

Use a shell directly, load it with direnv, compose its modules into your own
shell, or start from a template. The [README](../README.md) has the quick start.

The current major release is `v0`. Replace `vN` in the examples with the major
release you choose.

## Consumer patterns

### Pattern A — Direct use with isolated lock

Choose a shell's own flake and lock with `?dir=shells/<name>`. A lightweight
`mkShell` lock does not pull in the larger `devenv` dependency tree.

```bash
nix develop "github:dryvist/nix-devenv?dir=shells/tofu&ref=vN"
```

### Pattern B — `.envrc` in a project repo

Use direnv to load a remote shell with its own lock:

```bash
use flake "github:dryvist/nix-devenv?dir=shells/orchestrator&ref=vN" --impure
```

### Pattern C — Root flake

For one-off use, the root flake re-exports shells using its larger lock:

```bash
nix develop "github:dryvist/nix-devenv?ref=vN#tofu"
```

### Pattern D — Compose a shell

Importing this repo as an input adds it to your lock. Only projects that choose
to import it pay that cost.

```nix
inputs.nix-devenv.url = "github:dryvist/nix-devenv?ref=vN";
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

### Pattern E — Template scaffolding

```bash
nix flake init -t "github:dryvist/nix-devenv?ref=vN#mkshell"
nix flake init -t "github:dryvist/nix-devenv?ref=vN#devenv"
nix flake init -t "github:dryvist/nix-devenv?ref=vN#with-hooks"
```

## Available shells

| Kind | Shell | Tooling |
| --- | --- | --- |
| `mkShell` | `ansible` | Ansible, ansible-lint, Molecule, SOPS, age |
| `mkShell` | `tofu` | Terraform, OpenTofu, tflint, tfsec, Trivy; Terrakube workspace checks |
| `mkShell` | `kubernetes` | kubectl, Helm, helmfile, kustomize, k9s, kubeconform, kind |
| `mkShell` | `containers` | Docker, BuildKit, crane, skopeo |
| `mkShell` | `typescript` | Node.js 22 LTS, pnpm, TypeScript, ts-language-server, Biome |
| `mkShell` | `splunk-dev` | Python 3.9 via uv (EOL exception) |
| `mkShell` | `aws` | AWS CLI, aws-vault |
| `mkShell` | `azure` | Azure CLI |
| `mkShell` | `database` | PostgreSQL client (`psql`) |
| `mkShell` | `windows` | PowerShell 7 for Windows automation |
| `mkShell` | `server-admin` | IPMI/SoL, serial, PXE, ISO/firmware, network and disk diagnostics |
| `mkShell` | `server-admin-linux` | `server-admin` plus VNC, NVMe, NIC, and TFTP tools |
| `devenv` | `ai-dev` | LangChain, LangGraph, OpenTelemetry (pip venv) |
| `devenv` | `orchestrator` | LangGraph orchestration (uv + pyproject.toml) |
| `devenv` | `mlx-server` | MLX inference; aarch64-darwin only |

`tofu`, `ai-dev`, and `orchestrator` support x86_64 and aarch64 Linux, and
aarch64 macOS. `mlx-server` is limited to Apple Silicon.

Reusable modules: `devenvModules.python-ai` provides Python, LangChain, and
OpenTelemetry; `devenvModules.python-ml` provides Python and uv sync.

## Choose `mkShell` or `devenv`

Use `mkShell` for package lists, infrastructure tools, and minimal CI shells.
Use `devenv` when the environment needs services, process management, or
language tooling such as Python virtual environments. Infrastructure shells
stay `mkShell` unless they need those capabilities.

Each shell has its own `flake.nix` and `flake.lock`. The root flake, shell
flakes, and profile fixtures follow the published `channels` subflake; its
[`flake.nix`](../channels/flake.nix) owns the channel definitions, and each
consumer locks the published input independently.

## Credentials

Shells provide tools, not credentials. Never export a secret from `.envrc`:
direnv caches the resolved environment on disk. Mint short-lived credentials
when the command needs them.

Prefer the tool's credential provider. Git uses a credential helper, and AWS
tools use `credential_process`. For coordinates that are not secret, the
`tofu` shell can read `TF_CLOUD_HOSTNAME` and `TF_CLOUD_ORGANIZATION` from the
environment or run `TF_CLOUD_ENV_CMD`. An empty result aborts the shell.
`TERRAKUBE_ENV_OPTIONAL=1` skips that block for offline `tofu validate` only.
Do not export actual credentials from a `shellHook`; direnv persists its
environment just like `.envrc`.

For tools that only read credentials from environment variables, use a helper
function that mints a scoped token for each call. The shell definitions contain
no bootstrap credentials.

## Cachix cache

The `devenv` shells can use Cachix for binary substitutes:

```nix
nix.settings = {
  substituters = [ "https://devenv.cachix.org" ];
  trusted-public-keys = [ "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=" ];
};
```
