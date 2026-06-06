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
    # keymaps文件依赖
    plugins = {
      "smart-enter" = pkgs.yaziPlugins.smart-enter;
    };
    settings = import ./settings.nix;
    keymap = import ./keymaps.nix;
  };
}
