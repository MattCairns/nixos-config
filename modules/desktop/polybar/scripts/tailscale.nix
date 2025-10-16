{ pkgs, ... }:
let
  tailscale = "${pkgs.tailscale}/bin/tailscale";
  rg = "${pkgs.ripgrep}/bin/rg";
  hostname = "${pkgs.hostname}/bin/hostname";
  ip = "${pkgs.iproute2}/bin/ip";
  cut = "${pkgs.coreutils}/bin/cut";
  awk = "${pkgs.gawk}/bin/awk";
in
pkgs.writeShellScriptBin "tailscale-ctl" ''
  ${tailscale} status | ${rg} "$(${hostname})" &> /dev/null \
    && echo "%{F#2193ff}⍀  %{F#ffffff}[ts $(${ip} addr show tailscale0 | ${rg} 'inet ' | ${awk} '{print $2}' | ${cut} -d'/' -f1 )]" \
    || echo ""
''
