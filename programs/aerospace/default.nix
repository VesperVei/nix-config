{ pkgs, ... }:

{
  xdg.configFile."aerospace".source = ./config;

  home.packages = with pkgs; [
    aerospace
  ];
}
