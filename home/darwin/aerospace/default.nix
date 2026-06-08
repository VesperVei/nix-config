{ pkgs, ... }:

{
  xdg.configFile."aerospace/aerospace.toml".source = ./config/aerospace.toml;

  home.packages = with pkgs; [
    aerospace
  ];
}
