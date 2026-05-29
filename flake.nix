{
  description = "Whiteboard user Home Manager config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, ... }:
  let
    system = "aarch64-darwin";
    username = "zaochuan";
    homeDirectory = "/Users/${username}";
    hostname = "macbook";
  in {
    homeConfigurations."${username}@${hostname}" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};

      modules = [
        ./systems/darwin/macbook.nix
        {
          home.username = username;
          home.homeDirectory = homeDirectory;
        }
      ];
    };
  };
}

