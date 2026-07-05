{ lib, ... }: {
  imports = [
    ../../linux/tui.nix
  ];

  xdg.configFile."tmux/tmux.conf".source = lib.mkForce ./special/tmux.conf;
}
