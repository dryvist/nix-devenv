{ pkgs }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    # Provides the psql client; the server binaries in this package are inert here.
    postgresql
  ];
  shellHook = ''
    if [ -z "''${DIRENV_IN_ENVRC:-}" ]; then
      echo "Database Shell"
      echo "  - psql: $(psql --version 2>/dev/null)"
      echo ""
    fi
  '';
}
