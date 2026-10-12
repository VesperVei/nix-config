{ pkgs, ... }: {
  home.packages = with pkgs; ([
    zsteg # 图片隐写检测
    sleuthkit # 分析MFT工具
  ]);
}
