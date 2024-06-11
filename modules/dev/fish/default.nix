{pkgs, ...}: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      function fish_greeting
      end
      export OPENAI_API_KEY=$(cat ~/.config/secrets/openai-api-key)
      export TOGGL_API_KEY=$(cat ~/.config/secrets/toggl-api-key)
      atuin init fish | source
    '';
    plugins = [
      {
        name = "sponge";
        src = pkgs.fishPlugins.sponge.src;
      }
    ];
    shellAliases = {
      ls = "eza";
      nd = "nix develop";
      mkenv = "echo 'use flake' >> .envrc";
      du = "dust";
      grep = "rg";
    };
  };
}
