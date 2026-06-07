{pkgs, ...}: {
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    fastfetch
    nix-output-monitor # 负责提供美化底层
    nh # 负责提供高级 CLI 封装
    just
  ];
}
