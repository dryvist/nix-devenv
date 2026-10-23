{ pkgs, hook }:
let
  hookCommand = pkgs.lib.escapeShellArgs ([ hook.entry ] ++ hook.args);
in
pkgs.runCommand "private-identifier-hook-selftest"
  {
    nativeBuildInputs = [
      pkgs.gitMinimal
      pkgs.gnugrep
    ];
  }
  ''
    set -euo pipefail
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME/.config/gh-guard"
    printf '%s\n' 'zzforbiddenzz' > "$HOME/.config/gh-guard/identifiers.txt"

    mkdir repo
    cd repo
    git init -q
    git config user.name test
    git config user.email test@example.invalid
    printf 'safe\nsafe\n' > README.md
    git add README.md
    git commit -qm baseline

    printf 'safe\nZZFORBIDDENZZ\n' > README.md
    git add README.md
    if output="$(${hookCommand} 2>&1)"; then
      printf '%s\n' 'staged private identifier was not rejected' >&2
      exit 1
    fi
    case "$output" in
      *'README.md:2: private identifier'*) ;;
      *) printf '%s\n' 'the staged hit did not report its file and line' >&2; exit 1 ;;
    esac
    if printf '%s' "$output" | grep -qi 'zzforbiddenzz'; then
      printf '%s\n' 'the staged hit printed the matched value' >&2
      exit 1
    fi

    printf 'clean line\n' > README.md
    git add README.md
    if output="$(${hookCommand} 2>&1)"; then
      :
    else
      printf '%s\n' 'a clean staged change was rejected' >&2
      exit 1
    fi

    mv "$HOME/.config/gh-guard/identifiers.txt" "$HOME/identifiers.txt"
    printf 'zzforbiddenzz\n' > README.md
    git add README.md
    if output="$(${hookCommand} 2>&1)"; then
      :
    else
      printf '%s\n' 'a missing private list did not pass' >&2
      exit 1
    fi
    warnings="$(printf '%s\n' "$output" | grep -Fxc 'warning: private identifier list is absent; skipping local scan')"
    if [ "$warnings" -ne 1 ]; then
      printf '%s\n' 'a missing private list did not emit exactly one warning' >&2
      exit 1
    fi

    mkdir -p "$out"
    touch "$out/success"
  ''
