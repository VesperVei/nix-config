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
    username = "chenhun";
    homeDirectory = "/Users/chenhun";
  in {
    homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};

      modules = [
        ./home.nix
        {
          home.username = username;
          home.homeDirectory = homeDirectory;
        }
      ];
    };
  };
}
