{
  description = "OpenTofu infrastructure as code development environment";

  inputs = {
    # Channel pinned once in ../../channels; see channels/flake.nix.
    channels.url = "path:../../channels";
    nixpkgs.follows = "channels/nixpkgs";
    # Only opentofu is taken from here — see channels/flake.nix for why.
    nixpkgs-unstable.follows = "channels/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, nixpkgs-unstable, ... }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f {
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true; # Terraform uses BSL license
            };
            pkgsUnstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          }
        );
    in
    {
      devShells = forAllSystems (
        { pkgs, pkgsUnstable }:
        {
          default = import ./default.nix { inherit pkgs pkgsUnstable; };
        }
      );
    };
}
