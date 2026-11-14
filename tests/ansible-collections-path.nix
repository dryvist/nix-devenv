{ pkgs, shellHook }:
let
  hookScript = pkgs.writeText "ansible-shell-hook" shellHook;
in
pkgs.runCommand "ansible-collections-path-hook"
  {
    nativeBuildInputs = [
      pkgs.ansible
      pkgs.gitMinimal
      pkgs.jq
    ];
  }
  ''
    set -euo pipefail
    export HOME="$TMPDIR/home"
    export DIRENV_IN_ENVRC=1
    # ansible-core refuses to start without a UTF-8 locale.
    export LC_ALL=C.UTF-8
    defaults="$HOME/.ansible/collections:/usr/share/ansible/collections"
    mkdir -p "$HOME" "$TMPDIR/checkout/nested" "$TMPDIR/outside" "$TMPDIR/configured"
    git -C "$TMPDIR/checkout" -c init.defaultBranch=main init --quiet
    git -C "$TMPDIR/configured" -c init.defaultBranch=main init --quiet
    printf '[defaults]\ncollections_path = ./vendor/collections:/opt/shared\n' > "$TMPDIR/configured/ansible.cfg"

    (
      cd "$TMPDIR/checkout/nested"
      unset ANSIBLE_COLLECTIONS_PATH
      source "${hookScript}"
      test "$ANSIBLE_COLLECTIONS_PATH" = "$TMPDIR/checkout/.ansible/collections:$defaults"
    )

    (
      cd "$TMPDIR/checkout/nested"
      export ANSIBLE_COLLECTIONS_PATH=
      source "${hookScript}"
      test "$ANSIBLE_COLLECTIONS_PATH" = "$TMPDIR/checkout/.ansible/collections:$defaults"
    )

    (
      cd "$TMPDIR/checkout/nested"
      export ANSIBLE_COLLECTIONS_PATH=/x
      source "${hookScript}"
      test "$ANSIBLE_COLLECTIONS_PATH" = /x
    )

    (
      cd "$TMPDIR/configured"
      unset ANSIBLE_COLLECTIONS_PATH
      source "${hookScript}"
      test "$ANSIBLE_COLLECTIONS_PATH" = "$TMPDIR/configured/.ansible/collections:$TMPDIR/configured/vendor/collections:/opt/shared"
    )

    (
      cd "$TMPDIR/outside"
      export GIT_CEILING_DIRECTORIES="$TMPDIR"
      unset ANSIBLE_COLLECTIONS_PATH
      source "${hookScript}"
      test "$ANSIBLE_COLLECTIONS_PATH" = "$PWD/.ansible/collections:$defaults"
    )

    test ! -e "$TMPDIR/checkout/.ansible"
    test ! -e "$TMPDIR/configured/.ansible"
    test ! -e "$TMPDIR/outside/.ansible"
    mkdir -p "$out"
  ''
