{pkgs, llm-agents, ...}: {
  imports = [
    ../../linux/tui.nix
  ];

  home.packages = [
    llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
  ];
}
