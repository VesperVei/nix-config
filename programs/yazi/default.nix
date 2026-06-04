{pkgs, ...}: {
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
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;

    settings = import ./settings.nix;
    keymap = import ./keymaps.nix;
  };
}
