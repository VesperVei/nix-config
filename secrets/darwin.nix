{
  agenix,
  config,
  mysecrets,
  myvars,
  pkgs,
  ...
}: {
  imports = [
    agenix.darwinModules.default
  ];

  environment.systemPackages = [
    agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  age.identityPaths = [
    "/etc/ssh/ssh_host_ed25519_key"
  ];

  age.secrets = let
    user_readable = {
      mode = "0500";
      owner = myvars.username;
    };
  in {
    "ai-cli-api-keys.zsh" = {
      file = "${mysecrets}/ai-cli-api-keys.zsh.age";
    } // user_readable;
  };

}
