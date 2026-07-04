{
  mylib,
  myvars,
  genSpecialArgs,
  ...
}@args:
let
  name = myvars.darwinHostName;
in
{
  darwinConfigurations.${name} = mylib.macosSystem (
    args
    // {
      system = myvars.darwinSystem;
      username = myvars.username;
      homeDirectory = myvars.darwinHomeDirectory;
      specialArgs = genSpecialArgs myvars.darwinSystem;
      darwinModules = map mylib.relativeToRoot [
        "secrets/darwin.nix"
        "modules/darwin"
        "hosts/darwin-${name}"
      ];
      homeModules = map mylib.relativeToRoot [
        "home/hosts/darwin/darwin-${name}.nix"
      ];
    }
  );
}
