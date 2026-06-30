{ pkgs }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    azure-cli
    azure-storage-azcopy # `azcopy` blob/file transfer, co-located with az
  ];
  shellHook = ''
    if [ -z "''${DIRENV_IN_ENVRC:-}" ]; then
      echo "Azure Cloud Shell"
      echo "  - az: $(az version --output tsv 2>/dev/null | head -1)"
      echo "  - azcopy: $(azcopy --version 2>/dev/null | head -1)"
      echo ""
    fi
  '';
}
