{ pkgs, ... }:

{
  xdg.configFile."yazi".source = ./config;

  home.packages = with pkgs; [
    yazi
    fd
    ripgrep
    fzf
    zoxide
    jq
    imagemagick
    poppler
    ffmpegthumbnailer
    unar
    exiftool
    mediainfo
  ];
}
