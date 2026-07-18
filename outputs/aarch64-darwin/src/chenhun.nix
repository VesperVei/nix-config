{mkHome, ...} @ args: {
  homeConfigurations."chenhun@macbook" = mkHome {
    system = "aarch64-darwin";
    username = "chenhun";
    homeDirectory = "/Users/chenhun";
    modulePath = ../../../home/hosts/darwin/darwin-macbook.nix;
  };
}
