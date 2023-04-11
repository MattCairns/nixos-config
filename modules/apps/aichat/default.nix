{ config
, pkgs
, age
, ...
}: {
  age.secrets.chatgpt_api_key = {
    file = ../../../secrets/chatgpt_api_key.age;
  };
  xdg.configFile."aichat".source = ./i3blocks.conf;
  home.file.".config/aichat/config.yaml".text = ''
    api_key: ${config.age.secrets.chatgpt_api_key}
    save: true
  '';
}
