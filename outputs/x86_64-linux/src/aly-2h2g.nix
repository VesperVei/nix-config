{ mkHome, ... }@args:
{
  homeConfigurations."chun@aly-2h2g" = mkHome {
    system = "x86_64-linux";
    username = "chun";
    homeDirectory = "/home/chun";
    modulePath = ../../../home/hosts/linux/aly-2h2g.nix;
  };
}
