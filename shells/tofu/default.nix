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

  terrakubeEnv = pkgs.writeShellScriptBin "export-terrakube-env" ''
    export PATH="${
      pkgs.lib.makeBinPath [
        pkgs.git
        pkgs.coreutils
        pkgs.jq
        pkgs.curl
      ]
    }:$PATH"

    # Use the primary checkout's directory name so linked worktrees share a workspace.
    if repo_path=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null); then
      repo_name=$(basename "$(dirname "$repo_path")")
      printf 'export TF_WORKSPACE=%q\n' "$repo_name"
    fi

    if [ -n "''${BAO_ADDR:-}" ] \
      && [ -n "''${OPENBAO_APPROLE_TERRAFORM_ROLE_ID:-}" ] \
      && [ -n "''${OPENBAO_APPROLE_TERRAFORM_SECRET_ID:-}" ]; then
      _bao_token="$(
        jq -n \
          --arg role_id "''${OPENBAO_APPROLE_TERRAFORM_ROLE_ID}" \
          --arg secret_id "''${OPENBAO_APPROLE_TERRAFORM_SECRET_ID}" \
          '{role_id: $role_id, secret_id: $secret_id}' |
          curl -sSf --connect-timeout 3 --max-time 8 \
            -X POST "''${BAO_ADDR%/}/v1/auth/approle/login" \
            -H 'Content-Type: application/json' \
            --data @- |
          jq -r '.auth.client_token // empty' 2>/dev/null
      )"

      if [ -n "$_bao_token" ]; then
        curl -sSf --connect-timeout 3 --max-time 8 \
          -H "X-Vault-Token: $_bao_token" \
          "''${BAO_ADDR%/}/v1/secret/data/platform/terrakube/main" |
          jq -r '
            .data.data
            | {
                TF_CLOUD_HOSTNAME,
                TF_CLOUD_ORGANIZATION
              }
            | to_entries[]
            | select(.value != null)
            | "export \(.key)=\(.value | @sh)"
          ' 2>/dev/null
      fi
    fi
  '';
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
