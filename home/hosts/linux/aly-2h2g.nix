{ pkgs, llm-agents, ... }:
{
  imports = [
    ../../linux/low_config.nix
  ];

  home.packages = [
    llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
  ];
}
