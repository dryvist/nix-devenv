# OpenTofu Infrastructure as Code Shell
#
# Local authoring and validation tools for OpenTofu configurations executed by
# Terrakube. Terrakube obtains runtime credentials directly from OpenBao.
#
# NOTE: Caller must pass pkgs with config.allowUnfree = true for Terraform's BSL license.
#
# `pkgsUnstable` supplies opentofu alone and defaults to `pkgs`, so importing
# this file the old way still evaluates — it just gives you the stable version.
{
  pkgs,
  pkgsUnstable ? pkgs,
}:
let
  awsShell = import ../aws/default.nix { inherit pkgs; };

  # Body lives in scripts/ rather than inline: the previous inline form needed
  # ''${...} escaping on every shell expansion, which is how the failure paths
  # ended up untested and silent.
  terrakubeEnv = pkgs.writeShellApplication {
    name = "export-terrakube-env";
    runtimeInputs = with pkgs; [
      git
      coreutils
      jq
      curl
    ];
    text = builtins.readFile ./scripts/export-terrakube-env.sh;
  };
in
pkgs.mkShell {
  inputsFrom = [ awsShell ];
  buildInputs = with pkgs; [
    terrakubeEnv
    # === Infrastructure as Code ===
    terraform
    # Unstable, not the stable channel. Terrakube workspaces declare a version
    # constraint, and the CLI enforces it on any command that touches state
    # LOCALLY — `state rm`, `state mv`, `taint`. Plans and applies run remotely
    # and never noticed, so the shell looked fine right up until someone needed
    # to correct state, and then the only offered way forward was
    # `-ignore-remote-version`, which its own error text says may leave the
    # workspace unusable. Stable carried 1.11.8 against a `~> 1.12.0`
    # constraint. Drop this override once the stable channel catches up.
    pkgsUnstable.opentofu
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
