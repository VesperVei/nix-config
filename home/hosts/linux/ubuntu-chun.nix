{...}: {
  imports = [
    ../../../profiles/base.nix
    ../../../profiles/git.nix

    ../../../programs/nvim
    ../../../programs/yazi
    ../../../programs/tmux
    ../../../programs/zsh
    ../../../programs/eza
  ];
}
