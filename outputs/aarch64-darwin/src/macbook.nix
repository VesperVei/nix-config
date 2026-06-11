{
  inputs,
  mkHome,
  mylib,
  myvars,
  genSpecialArgs,
  ...
}: {
  homeConfigurations."${myvars.username}@${myvars.darwinHostName}" = mkHome {
    system = myvars.darwinSystem;
    username = myvars.username;
    homeDirectory = myvars.darwinHomeDirectory;
    # modulePath = ../../../home/hosts/darwin/darwin-zaochuan.nix;
    modulePath = mylib.relativeToRoot "home/hosts/darwin/darwin-${myvars.darwinHostName}.nix";
  };
  darwinConfigurations.${myvars.darwinHostName} = inputs.nix-darwin.lib.darwinSystem {
    system = myvars.darwinSystem;
    specialArgs = genSpecialArgs myvars.darwinSystem;
    modules = [
      (mylib.relativeToRoot "modules/darwin")
      (mylib.relativeToRoot "hosts/darwin-${myvars.darwinHostName}")
    ];
  };
}
