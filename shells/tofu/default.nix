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
in
pkgs.mkShell {
  inputsFrom = [ awsShell ];
  buildInputs = with pkgs; [
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
    openbao

    # === Development ===
    git
    python3

    # === Utilities ===
    jq
    yq
    pre-commit
    # NOTE: awscli2 + aws-vault inherited from awsShell via inputsFrom
  ];

  # Terrakube backend coordinates come from OpenBao and nowhere else. An empty
  # value fails here rather than later as OpenTofu's "organization must be
  # set", which names a config field instead of a failed secret fetch. Offline
  # validation (`tofu init -backend=false && tofu validate`) is the only
  # supported reason to continue without them, and it must be asked for. A
  # shell entered without the AppRole in its environment still opens; it says
  # which variables are missing and skips the fetch.
  shellHook = ''
    # Keyed on the remote, not the checkout path: every clone and linked
    # worktree of a repo shares one workspace wherever it sits on disk.
    if _remote="$(git config --get remote.origin.url 2>/dev/null)"; then
      export TF_WORKSPACE="$(basename -s .git "$_remote")"
    elif _gitdir="$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)"; then
      export TF_WORKSPACE="$(basename "$(dirname "$_gitdir")")"
    fi
    unset _remote _gitdir
    if [ -z "''${TERRAKUBE_ENV_OPTIONAL:-}" ]; then
      # Precondition, checked before any bao call. Unset, the CLI falls back to
      # its own compiled-in default address, nothing is listening there, and the
      # operator gets a connection refused that reads as "the secret store is
      # down" instead of "secret zero was never supplied to this shell".
      _terrakube_missing=""
      [ -n "''${BAO_ADDR:-}" ] || _terrakube_missing="$_terrakube_missing BAO_ADDR"
      [ -n "''${OPENBAO_APPROLE_TERRAFORM_ROLE_ID:-}" ] || _terrakube_missing="$_terrakube_missing OPENBAO_APPROLE_TERRAFORM_ROLE_ID"
      [ -n "''${OPENBAO_APPROLE_TERRAFORM_SECRET_ID:-}" ] || _terrakube_missing="$_terrakube_missing OPENBAO_APPROLE_TERRAFORM_SECRET_ID"
      if [ -n "$_terrakube_missing" ]; then
        echo "tofu shell: not set:$_terrakube_missing" >&2
        echo "" >&2
        echo "Backend coordinates come from OpenBao and nowhere else." >&2
        echo "  - Enter this directory under the secret-zero injector (doppler run -- ...) so the AppRole is ambient." >&2
        echo "  - Never substitute a locally stored token. No supported local copy exists." >&2
        echo "  - Offline validate only: TERRAKUBE_ENV_OPTIONAL=1" >&2
        echo "tofu shell: continuing without Terrakube backend coordinates." >&2
      else
        _bao_tok="$(printf '%s' "''${OPENBAO_APPROLE_TERRAFORM_SECRET_ID:-}" \
          | bao write -field=token auth/approle/login \
              role_id="''${OPENBAO_APPROLE_TERRAFORM_ROLE_ID:-}" secret_id=-)"
        TF_CLOUD_HOSTNAME="$(BAO_TOKEN="$_bao_tok" bao kv get -field=TF_CLOUD_HOSTNAME secret/platform/terrakube/main)"
        TF_CLOUD_ORGANIZATION="$(BAO_TOKEN="$_bao_tok" bao kv get -field=TF_CLOUD_ORGANIZATION secret/platform/terrakube/main)"
        unset _bao_tok
        if [ -z "$TF_CLOUD_HOSTNAME" ] || [ -z "$TF_CLOUD_ORGANIZATION" ]; then
          echo "tofu shell: OpenBao returned no Terrakube backend coordinates; TERRAKUBE_ENV_OPTIONAL=1 for offline validate only" >&2
          exit 1
        fi
        export TF_CLOUD_HOSTNAME TF_CLOUD_ORGANIZATION
      fi
      unset _terrakube_missing
    fi
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
