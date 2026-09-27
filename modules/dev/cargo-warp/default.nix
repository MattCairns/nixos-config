_: {
  programs.cargo-warp = {
    enable = true;
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
