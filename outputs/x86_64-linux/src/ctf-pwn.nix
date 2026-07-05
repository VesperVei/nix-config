{ mkHome, ... }@args:
{
  homeConfigurations."chen@ctf-pwn" = mkHome {
    system = "x86_64-linux";
    username = "chen";
    homeDirectory = "/home/chen";
    modulePath = ../../../home/hosts/linux/ctf-pwn.nix;
  };
}
