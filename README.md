# nix-devenv

Reusable Nix development shells for Terraform, Ansible, Kubernetes, Python/AI,
and more. This repo owns shell definitions and keeps the larger `devenv`
dependency tree out of lightweight shell locks.

[![OSV Scan][osv-badge]][osv-url]
[![Release Please][release-badge]][release-url]

[osv-badge]: https://github.com/dryvist/nix-devenv/actions/workflows/osv-scan.yml/badge.svg
[osv-url]: https://github.com/dryvist/nix-devenv/actions/workflows/osv-scan.yml
[release-badge]: https://github.com/dryvist/nix-devenv/actions/workflows/release-please.yml/badge.svg
[release-url]: https://github.com/dryvist/nix-devenv/actions/workflows/release-please.yml

## Quick start

Use Nix with flakes enabled. `direnv` is optional.

```bash
nix develop "github:dryvist/nix-devenv?dir=shells/ansible&ref=v0"
```

This opens the Ansible shell using its isolated lock file. See the
[consumer guide](docs/using-shells.md) to choose a shell, compose a shell into
your own flake, or see the supported tools and platforms.

## Other entry points

For a one-off shell using the larger root lock:

```bash
nix develop "github:dryvist/nix-devenv?ref=v0#ansible"
```

Scaffold a project from a template:

```bash
nix flake init -t "github:dryvist/nix-devenv?ref=v0#mkshell"
nix flake init -t "github:dryvist/nix-devenv?ref=v0#devenv"
nix flake init -t "github:dryvist/nix-devenv?ref=v0#with-hooks"
```

## Scope

This repo owns reusable development shells and templates. It does not provide
system or Home Manager modules. Lightweight `mkShell` environments have their
own locks; Python/AI shells that need services or language modules use
`devenv`.

Shells provide tools, not credentials. Do not export secrets from `.envrc`;
see the [consumer guide](docs/using-shells.md#credentials).

## Contributing

Shell authoring and validation steps are in [CLAUDE.md](CLAUDE.md). Workspace
conventions for commits, branches, signing, and pull requests live at
[docs.jacobpevans.com/conventions](https://docs.jacobpevans.com/conventions/overview).

## License

MIT.
