{ pkgs, ... }:
let
  desktopMode = pkgs.writeShellScriptBin "desktop-mode" (builtins.readFile ./desktop-mode.sh);
in
{
  home.packages = [ desktopMode ];
}
