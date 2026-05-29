{ pkgs, ... }:

{
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
fastfetch
  ];
}
╰─ cat home.nix                                                                                                                                                                                                   ─╯
{ pkgs, ... }:

{
imports = [./nvim];
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    fastfetch
    neovim
  ];
}
