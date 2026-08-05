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
  # Renovate has nothing to diff. deps-flake-lock.yml relocks this sub-flake and
  # then the root, whole-file, weekly.
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";

  # No outputs are needed: followers reference the `nixpkgs` INPUT via `follows`,
  # not an output. This flake exists purely to own the channel pin + its lock.
  outputs = { ... }: { };
}
