# Changelog

## [0.13.0](https://github.com/dryvist/nix-devenv/compare/v0.12.0...v0.13.0) (2026-06-25)


### Features

* **python:** mandate pyright + pytest, drop mypy (org standard sync) ([#56](https://github.com/dryvist/nix-devenv/issues/56)) ([5c54737](https://github.com/dryvist/nix-devenv/commit/5c54737adc1a1f7582c3a32a157b82e200b8d578))

## [0.12.0](https://github.com/dryvist/nix-devenv/compare/v0.11.0...v0.12.0) (2026-06-18)


### Features

* **hooks:** add docs profile via hygiene-core grandparent split ([#52](https://github.com/dryvist/nix-devenv/issues/52)) ([8b07c91](https://github.com/dryvist/nix-devenv/commit/8b07c91ae305b9f34f92fe408ef0862c00df7e0c))

## [0.11.0](https://github.com/dryvist/nix-devenv/compare/v0.10.1...v0.11.0) (2026-06-13)


### Features

* **ansible-shell:** add boto3/botocore so the native amazon.aws S3 inventory path works ([#50](https://github.com/dryvist/nix-devenv/issues/50)) ([b16f5cd](https://github.com/dryvist/nix-devenv/commit/b16f5cd470bd21f4a80fa3a9e0c0a731d9fe0357))

## [0.10.1](https://github.com/dryvist/nix-devenv/compare/v0.10.0...v0.10.1) (2026-06-12)


### Bug Fixes

* **ci:** repoint shared osv-scan workflow to dryvist hub ([#48](https://github.com/dryvist/nix-devenv/issues/48)) ([411d23c](https://github.com/dryvist/nix-devenv/commit/411d23c50082232bcd40a888543e3de6e8ac310c))

## [0.10.0](https://github.com/dryvist/nix-devenv/compare/v0.9.0...v0.10.0) (2026-06-11)


### Features

* **ansible:** add boto3 to the ansible shell python env ([#46](https://github.com/dryvist/nix-devenv/issues/46)) ([debdbf4](https://github.com/dryvist/nix-devenv/commit/debdbf41c88f0fcb283a66c2d1d1bb6298e746be))

## [0.9.0](https://github.com/dryvist/nix-devenv/compare/v0.8.1...v0.9.0) (2026-06-04)


### Features

* **shells:** add windows dev shell (PowerShell) ([#44](https://github.com/dryvist/nix-devenv/issues/44)) ([86d0df5](https://github.com/dryvist/nix-devenv/commit/86d0df5fc8edcd8033a93eb0eef131a84efbcbca))

## [0.8.1](https://github.com/dryvist/nix-devenv/compare/v0.8.0...v0.8.1) (2026-06-04)


### Bug Fixes

* **renovate:** re-enable shells/*/flake.lock maintenance ([#42](https://github.com/dryvist/nix-devenv/issues/42)) ([ee3f122](https://github.com/dryvist/nix-devenv/commit/ee3f1224d9ee2680c242b6256f175d0bc4f11e95))

## [0.8.0](https://github.com/dryvist/nix-devenv/compare/v0.7.0...v0.8.0) (2026-06-01)


### Features

* **flakeModules:** fetch shared configs + with-hooks template ([#35](https://github.com/dryvist/nix-devenv/issues/35)) ([eb5b4a3](https://github.com/dryvist/nix-devenv/commit/eb5b4a335349e586dbeaf155a53e577f5b881252))
* **flakeModules:** terraform/ansible/python profile modules ([#34](https://github.com/dryvist/nix-devenv/issues/34)) ([9896590](https://github.com/dryvist/nix-devenv/commit/9896590313511b1d0090d2642601307f87d174b7))


### Bug Fixes

* **ci:** repoint release-please caller to org-native reusable workflow ([#39](https://github.com/dryvist/nix-devenv/issues/39)) ([6aea03e](https://github.com/dryvist/nix-devenv/commit/6aea03e8bd1e45876ce3b0b9adeff1c36d50eef4))
* **ci:** retarget reusable-workflow uses: refs to current org homes ([#33](https://github.com/dryvist/nix-devenv/issues/33)) ([2dfb5e6](https://github.com/dryvist/nix-devenv/commit/2dfb5e621e1dd654ed0c287a1c1ddaa0c5c9ca8d))

## [0.7.0](https://github.com/JacobPEvans/nix-devenv/compare/v0.6.1...v0.7.0) (2026-05-24)


### Features

* **flakeModules:** mkPreCommitHooks + dev-hygiene module ([#31](https://github.com/JacobPEvans/nix-devenv/issues/31)) ([6831a8b](https://github.com/JacobPEvans/nix-devenv/commit/6831a8bca313bb3ba53b5a5b21f58a96db735314))

## [0.6.1](https://github.com/JacobPEvans/nix-devenv/compare/v0.6.0...v0.6.1) (2026-05-24)


### Bug Fixes

* **renovate:** use packageRule disable to skip nested shells/ sub-flakes ([#29](https://github.com/JacobPEvans/nix-devenv/issues/29)) ([e83806b](https://github.com/JacobPEvans/nix-devenv/commit/e83806b55162301959cccee0063e8d65a37b7109))

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
