{
  nix.enable = false;
  nix.settings.auto-optimise-store = false;
  nix.gc.automatic = false;
  system.stateVersion = 5;
}
