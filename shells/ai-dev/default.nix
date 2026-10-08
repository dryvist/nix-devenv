# AI Python Development Module (devenv)
#
# LangChain, LangGraph, and OpenTelemetry for AI application development.
# Uses pip venv for Python packages (requirements installed automatically).
{ pkgs, ... }:
let
  pwd = builtins.getEnv "PWD";
  pwdIsFlakeRoot = pwd != "" && builtins.pathExists (pwd + "/flake.nix");
in
{
  devenv.root = if pwdIsFlakeRoot then pwd else builtins.toString ./.;

  languages.python = {
    enable = true;
    package = import ../../lib/python.nix { inherit pkgs; };
    venv.enable = true;
    venv.requirements = ''
      harbor
      langchain
      langchain-core
      langchain-openai
      langgraph
      opentelemetry-api
      opentelemetry-sdk
      opentelemetry-exporter-otlp
      opentelemetry-instrumentation
    '';
  };
}
