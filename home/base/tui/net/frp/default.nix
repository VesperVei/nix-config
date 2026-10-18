{ pkgs, ... }: {
  xdg.configFile."frp".source = ./config;

  home.packages = with pkgs; [
    frp # 提供frps 和 frpc，做长连接转发
  ];
}
