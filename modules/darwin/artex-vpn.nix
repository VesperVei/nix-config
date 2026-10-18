{
  config,
  pkgs,
  myvars,
  ...
}:
let
  openvpn = "${pkgs.openvpn}/bin/openvpn";
  configPath = config.age.secrets."artex-vpn.ovpn".path;
in
{
  environment.systemPackages = [ pkgs.openvpn ];

  launchd.daemons.artex-vpn = {
    enable = true;
    config = {
      Label = "org.nixos.artex-vpn";
      ProgramArguments = [
        openvpn
        "--config"
        configPath
        "--writepid"
        "/var/run/artex-vpn.pid"
      ];
      RunAtLoad = true;
      KeepAlive = {
        SuccessfulExit = false;
        Crashed = true;
      };
      ProcessType = "Interactive";
      StandardOutPath = "/var/log/artex-vpn.log";
      StandardErrorPath = "/var/log/artex-vpn.log";
      ThrottleInterval = 10;
    };
  };
}
