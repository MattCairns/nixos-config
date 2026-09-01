{
  inputs,
  pkgs,
  ...
}: {
  programs.cargo-warp = {
    enable = true;
    package = inputs.cargo-warp.packages.${pkgs.system}.cargo-warp.overrideAttrs (finalAttrs: {
      cargoHash = "sha256-WbTLoTHXD/rqdrQh8H1tSfUlZiZrNMKYEDYRlLcjbjo=";
      cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
        name = "${finalAttrs.pname}-${finalAttrs.version}";
        inherit (finalAttrs) src;
        hash = "sha256-WbTLoTHXD/rqdrQh8H1tSfUlZiZrNMKYEDYRlLcjbjo=";
      };
    });
    settings = {
      defaults = {
        release = true;
      };
      hosts = {
        "dx*" = {
          target = "aarch64-unknown-linux-musl";
        };
        "dxlo" = {};
      };
    };
  };
}
