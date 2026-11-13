# Diagrams-as-Code Shell
#
# D2 for authoring and rendering, draw.io for opening, checking and exporting
# `.drawio` files from the command line, and Python for small converters.
#
# `pkgsUnstable` supplies d2 and drawio and defaults to `pkgs`, so importing
# this file without it still evaluates — it just gives the stable versions.
{
  pkgs,
  pkgsUnstable ? pkgs,
}:
pkgs.mkShell {
  buildInputs = [
    # Unstable, not the stable channel: stable d2 cannot export PNG any more
    # (the browser driver it downloads at first use was withdrawn upstream),
    # and draw.io files saved by a current release should be checked with one.
    pkgsUnstable.d2
    pkgsUnstable.drawio

    pkgs.python3
  ];

  shellHook = ''
    if [ -z "''${DIRENV_IN_ENVRC:-}" ]; then
      echo "═══════════════════════════════════════════════════════════════"
      echo "Diagrams Development Environment"
      echo "═══════════════════════════════════════════════════════════════"
      echo ""
      echo "  - d2:      $(d2 --version 2>/dev/null || echo 'available')"
      echo "  - drawio:  ${pkgsUnstable.drawio.version}"
      echo "  - python3: $(python3 --version 2>/dev/null || echo 'available')"
      echo ""
      echo "Getting Started:"
      echo "  Render:           d2 diagram.d2 diagram.svg"
      echo "  Export a drawio:  drawio -x -f png -o out.png in.drawio"
      echo ""
    fi
  '';
}
