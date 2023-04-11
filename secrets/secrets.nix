let
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMtxf6vcdvDoSx1IUtboLcK+EACy5H2E90apGqdHAyDe mattrcairns@gmail.com";
  systems = [ laptop ];
in
{
  "chatgpt_api_key.age".publicKeys = [ laptop ];
}
