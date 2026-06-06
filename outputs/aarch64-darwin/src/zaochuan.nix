{mkHome, ...} @ args: {
  homeConfigurations."zaochuan@macbook" = mkHome {
    system = "aarch64-darwin";
    username = "zaochuan";
    homeDirectory = "/Users/zaochuan";
    modulePath = ../../../home/hosts/darwin/darwin-zaochuan.nix;
  };
}
