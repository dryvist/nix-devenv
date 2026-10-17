# Container Development Shell
#
# Docker runtime, container building, and container registry tools.
# For Kubernetes orchestration and validation, use the kubernetes shell.
{ pkgs }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    # === Container Runtime ===
    docker

    # === Container Building ===
    buildkit

    # === Container Registry ===
    crane
    skopeo

    # === Utilities ===
    python3
    jq
    yq
  ];

  shellHook = ''
    if [ -z "''${DIRENV_IN_ENVRC:-}" ]; then
      echo "═══════════════════════════════════════════════════════════════"
      echo "Container Development & Registry Environment"
      echo "═══════════════════════════════════════════════════════════════"
      echo ""
      echo "Container Runtime & Building:"
      echo "  - docker:   $(docker --version 2>/dev/null || echo 'available')"
      echo "  - buildkit: $(buildctl --version 2>/dev/null || echo 'available')"
      echo ""
      echo "Container Registry:"
      echo "  - crane:  $(crane version 2>/dev/null || echo 'available')"
      echo "  - skopeo: $(skopeo --version 2>/dev/null || echo 'available')"
      echo ""
      echo "Getting Started:"
      echo "  Build image:      docker build -t <image>:<tag> ."
      echo "  List registry:    crane ls <registry>/<image>"
      echo "  Inspect image:    skopeo inspect docker://<image>"
      echo "  Copy image:       skopeo copy docker://<src> docker://<dst>"
      echo ""
      echo "Tip: For Kubernetes tools use the kubernetes shell."
      echo ""
    fi
  '';
}
