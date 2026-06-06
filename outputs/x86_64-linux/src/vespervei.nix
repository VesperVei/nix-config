{mkHome, ...} @ args: {
  homeConfigurations."chun@ubuntu-aly" = mkHome {
    system = "x86_64-linux";
    username = "chun";
    homeDirectory = "/home/chun";
    modulePath = ../../../home/hosts/linux/ubuntu-chun.nix;
  };
}
