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
      "piper" = pkgs.yaziPlugins.piper;
      "smart-enter" = pkgs.yaziPlugins.smart-enter;
    };
    settings = import ./settings.nix {inherit pkgs;};
    keymap = import ./keymaps.nix;
    theme = builtins.fromTOML (builtins.readFile ./config/theme.toml);
    flavors = {
      "catppuccin-mocha" = ./config/flavors/catppuccin-mocha.yazi;
    };
  };
}
