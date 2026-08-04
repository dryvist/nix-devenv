{
  # Single source of truth for the nixpkgs channel used by every shell in this
  # repo. nix forbids referencing a variable in `inputs` (input URLs must be
  # string literals), so the "define once, inherit everywhere" pattern is this
  # tiny pin flake: each shells/<name>/flake.nix declares
  #   channels.url = "path:../../channels";
  #   nixpkgs.follows = "channels/nixpkgs";
  # and the root flake follows it too. Bumping the channel is a one-line edit
  # here plus lockfile-only relocks in the followers (Renovate-able) — no more
  # editing the same string in 13+ files.
  description = "Single source of truth for the nixpkgs channel in nix-devenv.";

  # Channel branch = the intended major-version pin. Renovate cannot bump
  # this: a branch's reference never changes, only the commits on it do, so
  # Renovate has nothing to diff. deps-refresh-nixpkgs.yml relocks it weekly.
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";

  # Escape hatch for tools whose usable version outruns the stable channel.
  # A stable branch cannot cross a release boundary, so when a tool on it is
  # too old to do its job, waiting for the next release is the only other
  # option — six months, in the worst case.
  #
  # Use it for INDIVIDUAL PACKAGES, never for a whole shell. Every package
  # taken from here trades reproducibility for currency, so each one should be
  # able to point at the thing that broke without it. Today: opentofu in
  # shells/tofu, because Terrakube workspaces require ~> 1.12.0 and the stable
  # channel carries 1.11.8, which fails every local state command.
  inputs.nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  # No outputs are needed: followers reference the `nixpkgs` INPUT via `follows`,
  # not an output. This flake exists purely to own the channel pin + its lock.
  outputs = { ... }: { };
}
