{
  # DEPRECATED compatibility shim: this shell moved to shells/tofu (#73).
  # Kept so existing `.envrc` consumers pinned to ?dir=shells/terraform keep
  # working; migrate to ?dir=shells/tofu and delete this shim once no
  # consumer references it.
  description = "DEPRECATED alias of shells/tofu — OpenTofu development environment";

  inputs = {
    # Channel pinned once in ../../channels; see channels/flake.nix.
    channels.url = "path:../../channels";
    nixpkgs.follows = "channels/nixpkgs";
  };

  outputs =
    { nixpkgs, ... }:
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
          }
        );
    in
    {
      devShells = forAllSystems (
        { pkgs }:
        {
          default = import ../tofu/default.nix { inherit pkgs; };
        }
      );
    };
}
