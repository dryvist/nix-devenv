# Documentation (Markdown/MDX) pre-commit profile.
#
# Composes hygiene-core (file hygiene, nix lints, markdownlint, zizmor)
# WITHOUT treefmt. Consumer imports once:
#
#   imports = [ inputs.nix-devenv.flakeModules.docs ];
#
# Why a dedicated profile instead of `markdown` (an alias for dev-hygiene):
# docs sites built with Astro/Starlight/MDX carry hand-authored prose whose
# layout (tables, asides, line breaks) is intentional. The dev-hygiene base
# runs treefmt+prettier, which would reformat that prose; docs repos skip it
# by inheriting hygiene-core directly.
#
# Divergence from the base hygiene:
# * markdownlint-cli2 file glob widened to `.md` AND `.mdx` (the base hook
#   targets `.md` only). MDX-specific rule tuning (e.g. MD033 for JSX
#   components, MD041 for frontmatter-first files) stays in the consumer's
#   own .markdownlint config, auto-discovered by markdownlint-cli2.
{
  hygiene-core,
}:
{ lib, ... }:
{
  imports = [ hygiene-core ];

  perSystem = _: {
    pre-commit.settings.hooks.markdownlint-cli2.files = lib.mkForce "\\.(md|mdx)$";
  };
}
