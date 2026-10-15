{ pkgs, ... }: {
  home.packages = with pkgs; ([
    sqlmap # a inject tools for mysql database
    frp # 提供frps 和 frpc，做长连接转发
  ]);
}
