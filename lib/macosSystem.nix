{
  inputs,
  lib,
  myvars,
  system,
  genSpecialArgs,
  darwinModules,
  homeModules ? [ ],
  username ? myvars.username,
  homeDirectory ? "/Users/${username}",
  specialArgs ? (genSpecialArgs system),
  ...
}:
inputs.nix-darwin.lib.darwinSystem {
  inherit system specialArgs;
  modules =
    darwinModules
    ++ (lib.optionals ((lib.lists.length homeModules) > 0) [
      inputs.home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "home-manager.backup";
        home-manager.extraSpecialArgs = specialArgs;
        home-manager.users.${username}.imports = homeModules ++ [
          {
            home.username = username;
            home.homeDirectory = homeDirectory;
          }
        ];
      }
    ]);
}
