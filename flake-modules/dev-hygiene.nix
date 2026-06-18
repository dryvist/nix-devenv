# Org-wide dev-hygiene flake-parts module.
#
# Composes the universal hook set (hygiene-core) with treefmt:
# * hygiene-core    — git-hooks + lib.mkPreCommitHooks + zizmor policy
#                     (see flake-modules/hygiene-core.nix)
# * treefmt-nix     — formatter set (nixfmt, deadnix, statix, prettier,
#                     shfmt, taplo) with the org's standard options, wired
#                     in as the `treefmt` pre-commit hook
#
# This is the default base for code/IaC repos. Docs repos that don't want
# prettier reformatting authored Markdown/MDX import `hygiene-core`
# directly (via the `docs` profile) instead.
#
# Consumer:
#   {
#     inputs.nix-devenv.url = "github:JacobPEvans/nix-devenv";
#     outputs = inputs@{ flake-parts, ... }:
#       flake-parts.lib.mkFlake { inherit inputs; } {
#         imports = [ inputs.nix-devenv.flakeModules.dev-hygiene ];
#         # ... per-system / Claude-specific config ...
#       };
#   }
#
# That's it: no `inputs.treefmt-nix`, no `inputs.git-hooks`, no local
# treefmt.nix, no .github/zizmor.yml in consumers.
#
# The file is a function that nix-devenv's flake.nix calls eagerly with
# its own inputs (plus the pre-bound hygiene-core module), returning a
# flake-parts module.
{
  treefmt-nix,
  hygiene-core,
}:
{ ... }:
{
  imports = [
    hygiene-core
    treefmt-nix.flakeModule
  ];

  perSystem =
    {
      config,
      ...
    }:
    {
      treefmt = {
        projectRootFile = "flake.nix";
        programs = {
          nixfmt.enable = true;
          deadnix.enable = true;
          statix.enable = true;
          prettier.enable = true;
          shfmt.enable = true;
          taplo.enable = true;
        };
        settings.formatter.prettier.options = [
          "--print-width"
          "100"
        ];
        settings.formatter.shfmt.options = [
          "--indent"
          "2"
        ];
      };

      pre-commit.settings.hooks.treefmt = {
        enable = true;
        package = config.treefmt.build.wrapper;
      };
    };
}
