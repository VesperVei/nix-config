{ pkgs, ... }:

{
  home.file.".aerospace.toml".source = ./config/aerospace.toml;

  home.packages = with pkgs; [
    aerospace
  ];
}
