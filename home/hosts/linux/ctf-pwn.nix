{ lib, ... }: {
  imports = [
    ../../linux/tui.nix
  ];

  xdg.configFile."tmux".source = lib.mkForce ./special/tmux;
}
