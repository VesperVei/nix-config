{ pkgs, ... }: {
  home.packages = with pkgs; [
    zsteg # 图片隐写检测
    sleuthkit # 完整磁盘镜像取证
  ];
}
