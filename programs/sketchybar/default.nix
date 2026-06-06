{ pkgs, ... }:

{
  xdg.configFile."sketchybar".source = ./config;

  home.packages = with pkgs; [
    sketchybar
  ];

  launchd.agents.sketchybar = {
    enable = true;
    config = {
      ProgramArguments = [ "${pkgs.sketchybar}/bin/sketchybar" ];
      RunAtLoad = true;
      KeepAlive = true;
      EnvironmentVariables.PATH = "${pkgs.lib.makeBinPath [ pkgs.aerospace pkgs.sketchybar ]}:/usr/bin:/bin:/usr/sbin:/sbin";
      StandardOutPath = "/tmp/sketchybar.out.log";
      StandardErrorPath = "/tmp/sketchybar.err.log";
    };
  };
}
