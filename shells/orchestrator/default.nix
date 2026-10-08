# Orchestrator Development Module (devenv)
#
# Skill orchestration: LangGraph, LlamaIndex, embeddings.
# Uses uv for Python package management (reads pyproject.toml/uv.lock).
{ pkgs, ... }:
let
  pwd = builtins.getEnv "PWD";
  pwdIsOrchestratorRoot =
    pwd != ""
    && builtins.pathExists (pwd + "/pyproject.toml")
    &&
      builtins.match ".*name = \"orchestrator\".*" (builtins.readFile (pwd + "/pyproject.toml")) != null;
in
{
  devenv.root = if pwdIsOrchestratorRoot then pwd else builtins.toString ./.;

  # System libraries required by Python packages (qwen-agent needs libsndfile)
  packages = [ pkgs.libsndfile ];

  languages.python = {
    enable = true;
    package = import ../../lib/python.nix { inherit pkgs; };
    uv = {
      enable = true;
      sync = {
        enable = true;
        allExtras = true;
      };
    };
  };

  enterShell = ''
    # Activate uv-managed venv so Python sees installed packages
    if [ -f .venv/bin/activate ]; then
      source .venv/bin/activate
    fi
    echo "Orchestrator environment ready ($(python3 --version))"
  '';
}
