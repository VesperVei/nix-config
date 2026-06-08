{
  nixpkgs,
  home-manager,
  ...
} @ inputs: let
  inherit (inputs.nixpkgs) lib;
  mylib = import ../lib {inherit lib;};

  # outputs/default.nix
  genSpecialArgs = system:
    inputs
    // {
      inherit mylib;
    };

  mkHome = {
    system,
    username,
    homeDirectory,
    modulePath,
  }:
    home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};

      extraSpecialArgs = genSpecialArgs system;

      modules = [
        modulePath
        {
          home.username = username;
          home.homeDirectory = homeDirectory;
        }
      ];
    };

  args = {
    inherit inputs lib mkHome mylib genSpecialArgs;
  };

  darwin = import ./aarch64-darwin args;
  linux = import ./x86_64-linux args;
in {
  homeConfigurations = lib.attrsets.mergeAttrsList [
    (darwin.homeConfigurations or {})
    (linux.homeConfigurations or {})
  ];
}
