{
  config,
  pkgs,
  user,
  ...
}: {
  services.sxhkd = {
    enable = true;

    keybindings = {
      # Quick Open Hotkeys
      "super + ctrl + f" = "kitty -e vifm";
      "super + shift + w" = "firefox -P work";
      "super + shift + h" = "firefox -P home";
      "super + shift + s" = "kitty -e slack";
      "super + shift + g" = "kitty -e aichat";

      # terminal emulator
      "super + Return" = "kitty -e /home/$USER/.config/bin/ta";
      "super + ctrl + Return" = "kitty ";

      # program launcher
      "super + space" = "rofi -show drun";

      # make sxhkd reload its configuration files:
      "super + Escape" = "-USR1 -x sxhkd";

      # quit/restart bspwm
      "super + alt + {q,r}" = "bspc {quit,wm -r}";

      # close and kill
      "super + {_,shift + }w" = "bspc node -{c,k}";

      # Lock screen
      "super + shift + l" = "betterlockscreen -l";

      # alternate between the tiled and monocle layout
      "super + m" = "bspc desktop -l next";

      # send the newest marked node to the newest preselected node
      "super + y" = "bspc node newest.marked.local -n newest.!automatic.local";

      # swap the current node and the biggest window
      "super + g" = "bspc node -s biggest.window";

      # set the window state
      "super + {t,shift + t,s,f}" = "bspc node -t {tiled,pseudo_tiled,floating,fullscreen}";

      # set the node flags
      "super + ctrl + {m,x,y,z}" = "bspc node -g {marked,locked,sticky,private}";

      # focus the node in the given direction
      "super + {_,shift + }{h,j,k,l}" = "bspc node -{f,s} {west,south,north,east}";

      # focus the node for the given path jump
      "super + {p,b,comma,period}" = "bspc node -f @{parent,brother,first,second}";

      # focus the next/previous window in the current desktop
      "super + {_,shift + }c" = "bspc node -f {next,prev}.local.!hidden.window";

      # focus the next/previous desktop in the current monitor
      "super + bracket{left,right}" = "bspc desktop -f {prev,next}.local";

      # focus the last node/desktop
      "super + {grave,Tab}" = "bspc {node,desktop} -f last";

      # focus the older or newer node in the focus history
      "super + {o,i}" = "bspc wm -h off; \
      bspc node {older,newer} -f; \
      bspc wm -h on";

      # focus or send to the given desktop
      "super + {_,shift + }{1-9,0}" = "bspc {desktop -f,node -d} '^{1-9,10}'";

      # preselect the direction
      "super + ctrl + {h,j,k,l}" = "bspc node -p {west,south,north,east}";

      # preselect the ratio
      "super + ctrl + {1-9}" = "bspc node -o 0.{1-9}";

      # cancel the preselection for the focused node
      "super + ctrl + space" = "bspc node -p cancel";

      # cancel the preselection for the focused desktop
      "super + ctrl + shift + space" = "bspc query -N -d | xargs -I id -n 1 bspc node id -p cancel";

      # expand a window by moving one of its side outward
      "super + alt + {h,j,k,l}" = "bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}";

      # super + alt + shift + {h,j,k,l}
      "super + alt + shift + {h,j,k,l}" = "bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}";

      # move a floating window
      "super + {Left,Down,Up,Right}" = "bspc node -v {-20 0,0 20,0 -20,20 0}";

      # Connect to bluetooth headphones
      "super + shift + b" = "bluetoothctl connect 88:C9:E8:44:61:64";

      "XF86MonBrightnessDown " = "brightnessctl set 5%-";
      "XF86MonBrightnessUp " = "brightnessctl set 5%+";
      "XF86AudioLowerVolume" = "amixer set Master 5%-";
      "XF86AudioRaiseVolume" = "amixer set Master 5%+";
      "XF86AudioMute" = "amixer set Master toggle";
      "XF86AudioMicMute" = "amixer set Capture toggle";
      "XF86Display" = "";
      "XF86Favorites" = "";

      "super + shift + d" = "if [ $(dunstctl is-paused) = \"false\" ]; then dunstctl set-paused true; else dunstctl set-paused false && notify-send \"Dunst\" \"Turning ON notifications.\"; fi";
    };
  };
}
