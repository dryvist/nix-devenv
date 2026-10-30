# MLX Server Development Module (devenv)
#
# Apple Silicon only — MLX ships aarch64 wheels only.
# Uses uv for Python package management (reads pyproject.toml/uv.lock).
{ pkgs, ... }:
let
  pwd = builtins.getEnv "PWD";
  pwdIsMlxRoot = pwd != "" && builtins.pathExists (pwd + "/pyproject.toml");
in
{
  devenv.root = if pwdIsMlxRoot then pwd else "${./.}";

  languages.python = {
    enable = true;
    package = import ../../lib/python.nix { inherit pkgs; };
    uv = {
      enable = true;
      sync.enable = true;
    };
  };

  enterShell = ''
    # Set HF_HOME: use external volume if mounted, otherwise fall back
    if [ -d "/Volumes/HuggingFace" ] && [ -w "/Volumes/HuggingFace" ]; then
      export HF_HOME="/Volumes/HuggingFace"
    else
      export HF_HOME="''${XDG_CACHE_HOME:-''${HOME}/.cache}/huggingface"
      mkdir -p "''${HF_HOME}"
    fi
    echo "MLX environment ready ($(python3 --version))"
  '';
}
