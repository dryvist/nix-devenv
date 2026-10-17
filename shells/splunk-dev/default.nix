# Splunk Development Shell (Python 3.9 via uv)
#
# Python 3.9 is EOL and not available in nixpkgs, so this shell uses `uv`
# to download the interpreter on-demand from python-build-standalone.
#
# This is the ONLY Python environment that uses uv for packages.
# All other Python versions use Nix-only package management.
#
# Commands:
#   uv run --python 3.9 python script.py     # Run script
#   uv run --python 3.9 pytest tests/        # Run tests
#   uv run --python 3.9 --with splunk-sdk python  # With package
{ pkgs }:
pkgs.mkShell {
  name = "splunk-dev";

  buildInputs = with pkgs; [
    uv # Provides Python 3.9 on-demand
  ];

  shellHook = ''
    echo "======================================"
    echo "Splunk Development (Python 3.9 via uv)"
    echo "======================================"
    echo ""
    echo "Python 3.9 is EOL and not in nixpkgs."
    echo "uv downloads it on-demand (~30MB, cached)."
    echo ""
    echo "Usage:"
    echo "  uv run --python 3.9 python script.py"
    echo "  uv run --python 3.9 pytest tests/"
    echo "  uv run --python 3.9 --with splunk-sdk python"
    echo ""

    # Pre-fetch Python 3.9
    if ! uv python find 3.9 >/dev/null 2>&1; then
      echo "Downloading Python 3.9..."
      uv python install 3.9
    fi
  '';
}
