# Terraform/OpenTofu pre-commit profile.
#
# Composes dev-hygiene (base hooks: nix lints, file hygiene, markdownlint,
# zizmor) with terraform-specific hooks. Consumer imports once:
#
#   imports = [ inputs.nix-devenv.flakeModules.terraform ];
#
# Enabled on top of base:
# * terraform-format   — `terraform fmt -recursive` on changed .tf files
# * terraform-validate — `terraform validate` per module (initializes a
#                        local backend; safe in pre-commit)
# * tflint             — Terraform linter; per-repo .tflint.hcl picked up
#                        from the worktree if present
#
# checkov is intentionally not in this profile: only ~3 of the inventoried
# terraform repos used it, and its run time dominates the hook cycle. Repos
# that want it enable `pre-commit.settings.hooks.checkov.enable = true;`
# locally.
{
  dev-hygiene,
}:
{ ... }:
{
  imports = [ dev-hygiene ];

  perSystem = _: {
    pre-commit.settings.hooks = {
      terraform-format.enable = true;
      terraform-validate.enable = true;
      tflint.enable = true;
    };
  };
}
