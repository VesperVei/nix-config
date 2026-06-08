# Justfile - 用于一键自动化你的 Nix 工作流

# 首次新机器冷启动（空降 nh 丝滑构建）
bootstrap config_name:
    nix run nixpkgs#nh -- home switch . -- "{{config_name}}"

# 以后日常修改配置后的常规热更新
switch:
    nh home switch
