{ inputs, pkgs, ... }:
{
  task.package = inputs.devenv.packages.${pkgs.stdenv.hostPlatform.system}.devenv-tasks;
}
