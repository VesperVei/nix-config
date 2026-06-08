{ pkgs, ... }:

{
  xdg.configFile."tmux".source = ./config;

  home.packages = with pkgs; [
    tmux
  ];
}
