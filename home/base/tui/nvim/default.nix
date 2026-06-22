{ pkgs, ... }:

{
  xdg.configFile."nvim".source = ./config;

  home.shellAliases = {
    vim = "nvim";
  };

  home.packages = with pkgs; [
    neovim

    git
    lazygit
    ripgrep
    fd
    tree-sitter
  ];
}
