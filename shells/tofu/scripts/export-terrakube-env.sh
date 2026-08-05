#!/usr/bin/env bash
# Emit the Terrakube backend coordinates as shell exports, read from OpenBao.
#
# OpenBao is the only source. There is deliberately no local fallback: a
# locally stored Terrakube token is what this helper exists to make
# unnecessary, and a fallback would quietly re-create it.
#
# Failing loudly is the whole point. This previously wrapped everything in a
# test for three variables being non-empty and skipped the block when any was
# missing — exiting 0 having emitted nothing. The operator then got OpenTofu's
# own error, "organization must be set", which names a config field rather than
# a failed secret fetch, sending them to look in the wrong repo. The usual next
# move was to stash a token somewhere local.
set -euo pipefail

# Offline validation (`tofu init -backend=false && tofu validate`) needs no
# backend coordinates. That is the only supported reason to continue without
# them, and it must be asked for explicitly.
fail() {
  if [ -n "${TERRAKUBE_ENV_OPTIONAL:-}" ]; then
    printf '# export-terrakube-env: %s (TERRAKUBE_ENV_OPTIONAL set, continuing)\n' "$1" >&2
    exit 0
  fi
  printf 'export-terrakube-env: %s\n' "$1" >&2
  printf '\n' >&2
  printf 'Backend coordinates come from OpenBao and nowhere else.\n' >&2
  printf '  - Run the command under the secret-zero injector so the AppRole is ambient.\n' >&2
  printf '  - A connection refused in ~2ms is host-level network policy, not an outage.\n' >&2
  printf '    Re-run from a terminal that is permitted to reach the local network.\n' >&2
  printf '  - Never substitute a locally stored token. No supported local copy exists.\n' >&2
  printf '  - Offline validate only: TERRAKUBE_ENV_OPTIONAL=1\n' >&2
  exit 1
}

# Use the primary checkout's directory name so linked worktrees share a workspace.
if repo_path=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null); then
  printf 'export TF_WORKSPACE=%q\n' "$(basename "$(dirname "$repo_path")")"
fi

[ -n "${BAO_ADDR:-}" ] || fail "BAO_ADDR is not set"
[ -n "${OPENBAO_APPROLE_TERRAFORM_ROLE_ID:-}" ] || fail "terraform AppRole role_id is not set"
[ -n "${OPENBAO_APPROLE_TERRAFORM_SECRET_ID:-}" ] || fail "terraform AppRole secret_id is not set"

bao_token="$(
  jq -n \
    --arg role_id "${OPENBAO_APPROLE_TERRAFORM_ROLE_ID}" \
    --arg secret_id "${OPENBAO_APPROLE_TERRAFORM_SECRET_ID}" \
    '{role_id: $role_id, secret_id: $secret_id}' |
    curl -sSf --connect-timeout 3 --max-time 8 \
      -X POST "${BAO_ADDR%/}/v1/auth/approle/login" \
      -H 'Content-Type: application/json' \
      --data @- |
    jq -r '.auth.client_token // empty'
)" || fail "AppRole login against OpenBao failed"
[ -n "$bao_token" ] || fail "AppRole login returned no token"

payload="$(
  curl -sSf --connect-timeout 3 --max-time 8 \
    -H "X-Vault-Token: $bao_token" \
    "${BAO_ADDR%/}/v1/secret/data/platform/terrakube/main"
)" || fail "could not read the Terrakube backend coordinates from OpenBao"

rendered="$(
  printf '%s' "$payload" | jq -r '
    .data.data
    | { TF_CLOUD_HOSTNAME, TF_CLOUD_ORGANIZATION }
    | to_entries[]
    | select(.value != null and .value != "")
    | "export \(.key)=\(.value | @sh)"
  '
)" || fail "could not parse the Terrakube backend coordinates"

# Assert on the rendered output, not merely on the fetch succeeding. A 200
# whose payload is missing a key still produces a shell with no backend
# configured, which is the silent-success case this helper must never emit.
for required in TF_CLOUD_HOSTNAME TF_CLOUD_ORGANIZATION; do
  case "$rendered" in
    *"export $required="*) ;;
    *) fail "OpenBao returned no $required" ;;
  esac
done

printf '%s\n' "$rendered"
