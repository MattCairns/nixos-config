{
  lib,
  pkgs,
  ...
}: let
  chatgpt = pkgs.stdenv.mkDerivation {
    pname = "chatgpt";
    version = "26.901.51231";

    src = pkgs.fetchurl {
      url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb";
      hash = "sha256-YlgBiNh8PTqTadq3xztCqKMlGNTfii1brmRm3erFwF4=";
    };

    nativeBuildInputs = [
      pkgs.autoPatchelfHook
      pkgs.dpkg
    ];

    buildInputs = with pkgs; [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      atk
      cairo
      cups
      dbus
      expat
      gdk-pixbuf
      glib
      gtk3
      libdrm
      libgbm
      libnotify
      libusb1
      libX11
      libXcomposite
      libXdamage
      libXext
      libXfixes
      libXi
      libXrandr
      libXScrnSaver
      libXtst
      libXcursor
      libxcb
      libxkbcommon
      libglvnd
      mesa
      nspr
      nss
      pango
      stdenv.cc.cc.lib
      systemd
      wayland
    ];

    autoPatchelfIgnoreMissingDeps = [
      "libQt5Core.so.5"
      "libQt5Gui.so.5"
      "libQt5Widgets.so.5"
      "libQt6Core.so.6"
      "libQt6Gui.so.6"
      "libQt6Widgets.so.6"
      "libc.musl-x86_64.so.1"
    ];

    dontConfigure = true;
    dontBuild = true;

    unpackPhase = ''
      dpkg-deb --extract "$src" .
    '';

    installPhase = ''
      mkdir -p "$out"
      cp -a usr/bin usr/lib usr/share "$out/"
    '';

    meta = {
      description = "ChatGPT desktop app for Linux";
      homepage = "https://chatgpt.com/";
      license = lib.licenses.unfree;
      mainProgram = "chatgpt";
      platforms = ["x86_64-linux"];
    };
  };
in {
  home.packages = lib.optional (pkgs.stdenv.hostPlatform.system == "x86_64-linux") chatgpt;
}
