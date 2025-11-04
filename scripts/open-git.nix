{ pkgs }:
pkgs.writeShellScriptBin "open-git" /* bash */ ''

  cd $(${pkgs.tmux}/bin/tmux run "echo #{pane_start_path}")
  url=$(${pkgs.git}/bin/git remote get-url origin)

  if [[ $url == git@* ]]; then
    url=$(echo "$url" | sed 's/^git@//' | sed 's/:/\//')
  fi
  ${pkgs.firefox}/bin/firefox -p work "$url"
''
