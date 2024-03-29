# Matts Rice
This repo is constantly evolving to suite my purposes and contains everything I need to quickly configure and use my work, personal and laptop computers.

<p align="center">
  <img src="assets/screenshots/desktop-wallpaper.png" width="700" />
  <img src="assets/screenshots/neofetch.png" width="700" /> 
</p>

## Some of whats included
- Fully configured Neovim with lots of fun plugins.
  - Treesitter
  - lsp
  - completion
  - debugging for C++/Rust
  - Much more
- Firefox profiles for Work and Home 
  - Removal of annoying firefox things like the password saving
  - Clear data on quit
  - Disable telemetry, pocket, studies, etc
- tmux
  - Builtin scripts to run tmux on terminal open 
  - Quickly switch between projects in tmux using [tmux-sessionizer](https://github.com/jrmoulton/tmux-sessionizer)


## Dependencies
- NixOS.  

If you have NixOS then installation is a simple as:

```bash
cd ~
git clone git@github.com:MattCairns/nixos-config.git
cp /etc/nixos/hardware-configuration.nix ~/nixos-config/machines/<MACHINE>/.
cd ~/nixos-config/
sudo nixos-rebuild switch --flake .#<MACHINE>
sudo reboot now
```

If you dont have NixOS feel free to pull stuff out of here for your own purposes.
