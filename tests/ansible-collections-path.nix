{ pkgs, shellHook }:
let
  hookScript = pkgs.writeText "ansible-shell-hook" shellHook;
in
pkgs.runCommand "ansible-collections-path-hook"
  {
    nativeBuildInputs = [ pkgs.gitMinimal ];
  }
  ''
    set -euo pipefail
    export HOME="$TMPDIR/home"
    export DIRENV_IN_ENVRC=1
    mkdir -p "$HOME" "$TMPDIR/checkout/nested" "$TMPDIR/outside"
    git -C "$TMPDIR/checkout" -c init.defaultBranch=main init --quiet

    (
      cd "$TMPDIR/checkout/nested"
      unset ANSIBLE_COLLECTIONS_PATH
      source "${hookScript}"
      test "$ANSIBLE_COLLECTIONS_PATH" = "$TMPDIR/checkout/.ansible/collections"
    )

    (
      cd "$TMPDIR/checkout/nested"
      export ANSIBLE_COLLECTIONS_PATH=
      source "${hookScript}"
      test "$ANSIBLE_COLLECTIONS_PATH" = "$TMPDIR/checkout/.ansible/collections"
    )

    (
      cd "$TMPDIR/checkout/nested"
      export ANSIBLE_COLLECTIONS_PATH=/x
      source "${hookScript}"
      test "$ANSIBLE_COLLECTIONS_PATH" = /x
    )

    (
      cd "$TMPDIR/outside"
      export GIT_CEILING_DIRECTORIES="$TMPDIR"
      unset ANSIBLE_COLLECTIONS_PATH
      source "${hookScript}"
      test "$ANSIBLE_COLLECTIONS_PATH" = "$PWD/.ansible/collections"
    )

    test ! -e "$TMPDIR/checkout/.ansible"
    test ! -e "$TMPDIR/outside/.ansible"
    mkdir -p "$out"
  ''
