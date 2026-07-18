{ pkgs, ... }:

{
  xdg.configFile."aerospace/aerospace.toml".source = ./config/aerospace.toml;

  home.packages = with pkgs; [
    aerospace
  ];

  launchd.agents.aerospace = {
    enable = true;
    config = {
      ProgramArguments = [ "/usr/bin/open" "-ga" "AeroSpace" ];
      RunAtLoad = true;
      KeepAlive = false;
      StandardOutPath = "/tmp/aerospace.out.log";
      StandardErrorPath = "/tmp/aerospace.err.log";
    };
  };
}
