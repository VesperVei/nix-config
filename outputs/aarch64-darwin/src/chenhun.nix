{mkHome, ...} @ args: {
  homeConfigurations."chenhun@macbook" = mkHome {
    system = "aarch64-darwin";
    username = "chenhun";
    homeDirectory = "/Users/chenhun";
    # 未配置chenhun的module模块
    modulePath = ../../../home/hosts/darwin/darwin-zaochuan.nix;
  };
}
