{config, ...}: {
  home.sessionVariables = {
    NH_FLAKE = "${config.home.homeDirectory}/nix-config";
  };
}
