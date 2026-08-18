{ pkgs, ... }:

let
  aerospaceConfig = pkgs.writeText "aerospace.toml" (
    builtins.concatStringsSep "\n\n" [
      (builtins.readFile ./config/aerospace.toml)
      (builtins.readFile ./config/aerospace-dual-monitor.toml)
    ]
  );
in
{
  xdg.configFile."aerospace/aerospace.toml".source = aerospaceConfig;

  home.packages = with pkgs; [
    aerospace
  ];

  launchd.agents.aerospace = {
    enable = true;
    config = {
      ProgramArguments = [
        "/usr/bin/open"
        "-ga"
        "AeroSpace"
      ];
      RunAtLoad = true;
      KeepAlive = false;
      StandardOutPath = "/tmp/aerospace.out.log";
      StandardErrorPath = "/tmp/aerospace.err.log";
    };
  };
}
