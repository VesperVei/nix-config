{ pkgs, ... }:

{
  xdg.configFile."nvim".source = ./config;

  home.shellAliases = {
    vim = "nvim";
  };

  home.packages = with pkgs; [
    neovim

    git
    ripgrep
    fd
    tree-sitter

    clang-tools
    lua-language-server
    pyright
    typescript-language-server
    vscode-langservers-extracted
    tailwindcss-language-server
    svelte-language-server
    emmet-ls
    bash-language-server
    nil

    prettier
    stylua
    alejandra
    black
    isort
    eslint_d
  ];
}
