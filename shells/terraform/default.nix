# OpenTofu Infrastructure as Code Shell
#
# Local authoring and validation tools for OpenTofu configurations executed by
# Terrakube. Terrakube obtains runtime credentials directly from OpenBao.
#
# NOTE: Caller must pass pkgs with config.allowUnfree = true for Terraform's BSL license.
{ pkgs }:
let
  awsShell = import ../aws/default.nix { inherit pkgs; };
in
pkgs.mkShell {
  inputsFrom = [ awsShell ];
  buildInputs = with pkgs; [
    # === Infrastructure as Code ===
    terraform
    opentofu
    terraform-docs
    tflint

    # === Security & Compliance ===
    # checkov and terrascan removed: checkov is broken in nixpkgs
    # (pycep-parser fails to build with uv_build backend). Both hooks are
    # also disabled in terraform-proxmox .pre-commit-config.yaml. Re-add
    # when the upstream nixpkgs pycep-parser derivation is fixed.
    tfsec
    trivy

    # === Secrets Management ===
    sops
    age

    # === Development ===
    git
    python3

    # === Utilities ===
    jq
    yq
    pre-commit
    # NOTE: awscli2 + aws-vault inherited from awsShell via inputsFrom
  ];

  shellHook = ''
    if [ -z "''${DIRENV_IN_ENVRC:-}" ]; then
      echo "═══════════════════════════════════════════════════════════════"
      echo "OpenTofu Infrastructure as Code Environment"
      echo "═══════════════════════════════════════════════════════════════"
      echo ""
      echo "Infrastructure as Code:"
      echo "  - terraform: $(terraform version -json 2>/dev/null | jq -r '.terraform_version' 2>/dev/null || terraform version | head -1)"
      echo "  - opentofu: $(tofu version 2>/dev/null | head -1)"
      echo ""
      echo "Security & Compliance:"
      echo "  - tfsec: $(tfsec --version 2>/dev/null)"
      echo ""
      echo "Secrets Management:"
      echo "  - sops: $(sops --version 2>/dev/null)"
      echo "  - age: $(age --version 2>/dev/null)"
      echo ""
      echo "Cloud:"
      echo "  - aws-cli: $(aws --version 2>/dev/null)"
      echo ""
      echo "Getting Started:"
      echo "  1. Author and validate locally with OpenTofu"
      echo "  2. Run plans and applies in Terrakube"
      echo "  3. Let Terrakube inject short-lived credentials from OpenBao"
      echo "  4. Setup pre-commit hooks: pre-commit install"
      echo ""
    fi
  '';
}
