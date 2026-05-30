{ pkgs, ... }:

{
  xdg.configFile."sketchybar".source = ./config;

  home.packages = with pkgs; [
    sketchybar
  ];
}
