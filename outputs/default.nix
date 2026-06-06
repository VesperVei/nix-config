{
  nixpkgs,
  home-manager,
  ...
} @ inputs: let
  inherit (inputs.nixpkgs) lib;

  mkHome = {
    system,
    username,
    homeDirectory,
    modulePath,
  }:
    home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};

      modules = [
        modulePath
        {
          home.username = username;
          home.homeDirectory = homeDirectory;
        }
      ];
    };

  args = {
    inherit inputs lib mkHome;
  };

  darwin = import ./aarch64-darwin args;
in {
  homeConfigurations = lib.attrsets.mergeAttrsList [
    (darwin.homeConfigurations or {})
  ];
}
