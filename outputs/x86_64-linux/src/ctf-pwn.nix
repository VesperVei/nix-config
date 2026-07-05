{ mkHome, ... }@args:
{
  homeConfigurations."chen@pwnus" = mkHome {
    system = "x86_64-linux";
    username = "chen";
    homeDirectory = "/home/chen";
    modulePath = ../../../home/hosts/linux/ubuntu-chun.nix;
  };
}
