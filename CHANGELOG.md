# Changelog

## [0.6.0](https://github.com/JacobPEvans/nix-devenv/compare/v0.5.2...v0.6.0) (2026-05-10)


### Features

* **shells:** add server-admin and server-admin-linux dev shells ([#25](https://github.com/JacobPEvans/nix-devenv/issues/25)) ([a9da7bd](https://github.com/JacobPEvans/nix-devenv/commit/a9da7bdddee2a9bc859d420bb6ae3beb9b2420e0))

## [0.5.2](https://github.com/JacobPEvans/nix-devenv/compare/v0.5.1...v0.5.2) (2026-05-03)


### Bug Fixes

* **ci:** remove deprecated app-id secret passthrough ([bd3ebcf](https://github.com/JacobPEvans/nix-devenv/commit/bd3ebcf9bf964560827bc675fded38665dfe8c6b))

## [0.5.1](https://github.com/JacobPEvans/nix-devenv/compare/v0.5.0...v0.5.1) (2026-04-26)


### Bug Fixes

* **ci:** upgrade renovate to v5 (json5) ([#20](https://github.com/JacobPEvans/nix-devenv/issues/20)) ([19bd950](https://github.com/JacobPEvans/nix-devenv/commit/19bd95046588dff1764f8de2f72e2e9d934c16a9))

## [0.5.0](https://github.com/JacobPEvans/nix-devenv/compare/v0.4.2...v0.5.0) (2026-04-11)


### Features

* receive project-scoped tools from nix-home; add python-base module ([#17](https://github.com/JacobPEvans/nix-devenv/issues/17)) ([f9a43fa](https://github.com/JacobPEvans/nix-devenv/commit/f9a43fa95ff2232f82e24a0298ebb5926e17b6b1))

## [0.4.2](https://github.com/JacobPEvans/nix-devenv/compare/v0.4.1...v0.4.2) (2026-04-01)


### Bug Fixes

* **renovate:** add Renovate config extending org-wide preset ([#15](https://github.com/JacobPEvans/nix-devenv/issues/15)) ([633446c](https://github.com/JacobPEvans/nix-devenv/commit/633446cc5851099ab8e83ac4bf5cdac9ded3a8be))

## [0.4.1](https://github.com/JacobPEvans/nix-devenv/compare/v0.4.0...v0.4.1) (2026-03-31)


### Bug Fixes

* **deps:** switch to nixpkgs-25.11-darwin and update all flake inputs ([#13](https://github.com/JacobPEvans/nix-devenv/issues/13)) ([28208ca](https://github.com/JacobPEvans/nix-devenv/commit/28208ca13889637faf8e3b30da9c7a24448e33c1))

## [0.4.0](https://github.com/JacobPEvans/nix-devenv/compare/v0.3.1...v0.4.0) (2026-03-30)


### Features

* prepare shells for cross-repo DRY consolidation ([#11](https://github.com/JacobPEvans/nix-devenv/issues/11)) ([c234019](https://github.com/JacobPEvans/nix-devenv/commit/c234019ab00ae52dac005a01c622f7d4fffaa8ba))

## [0.3.1](https://github.com/JacobPEvans/nix-devenv/compare/v0.3.0...v0.3.1) (2026-03-29)


### Bug Fixes

* **deps:** centralize Python version in lib/python.nix ([#9](https://github.com/JacobPEvans/nix-devenv/issues/9)) ([a9486b8](https://github.com/JacobPEvans/nix-devenv/commit/a9486b8dc0d48c1dc066ff90ed2b791615c7faa8))

## [0.3.0](https://github.com/JacobPEvans/nix-devenv/compare/v0.2.1...v0.3.0) (2026-03-22)


### Features

* **orchestrator:** sync all pyproject.toml extras in devenv shell ([8bfcd16](https://github.com/JacobPEvans/nix-devenv/commit/8bfcd16aa57fc07d603f9b270a265c76f5fa6ec3))

## [0.2.1](https://github.com/JacobPEvans/nix-devenv/compare/v0.2.0...v0.2.1) (2026-03-22)


### Bug Fixes

* add default devShell for repo development ([cd540e0](https://github.com/JacobPEvans/nix-devenv/commit/cd540e02270118423af639df5cd0666c60efc11f))

## [0.2.0](https://github.com/JacobPEvans/nix-devenv/compare/v0.1.0...v0.2.0) (2026-03-20)


### Features

* add composable aws and azure cloud CLI dev shells ([#2](https://github.com/JacobPEvans/nix-devenv/issues/2)) ([07d6979](https://github.com/JacobPEvans/nix-devenv/commit/07d6979f20c3e605acfec5ef5db8e7db2c4b96a2))
* add release-please automation ([4bf5cb4](https://github.com/JacobPEvans/nix-devenv/commit/4bf5cb46911b10ef7983dca56041d36b8658804d))
* initial nix-devenv repo with 8 shells, modules, and templates ([40859bd](https://github.com/JacobPEvans/nix-devenv/commit/40859bd5b81a4037f01f26f9bd896f560ab2c865))
