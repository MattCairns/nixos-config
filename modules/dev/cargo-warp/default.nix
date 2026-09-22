{
  inputs,
  pkgs,
  ...
}: {
  programs.cargo-warp = {
    enable = true;
    package = inputs.cargo-warp.packages.${pkgs.stdenv.hostPlatform.system}.cargo-warp.overrideAttrs (finalAttrs: {
      cargoHash = "sha256-Lp0Oljkdit0hHbGF4bu9OLK2WagTGiCa5z8jq+GV5d4=";
      cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
        name = "${finalAttrs.pname}-${finalAttrs.version}";
        inherit (finalAttrs) src;
        hash = "sha256-Lp0Oljkdit0hHbGF4bu9OLK2WagTGiCa5z8jq+GV5d4=";
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
