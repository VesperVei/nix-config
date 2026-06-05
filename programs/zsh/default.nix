{
  config,
  pkgs,
  lib,
  ...
}: let
  # 1. 定义脚本目录
  scriptDir = ./scripts;

  # 2. 自动获取目录下所有以 .zsh 结尾的文件，并生成 source 语句
  # 过滤掉 init.zsh 本身（如果你还保留它的话）
  customModules = builtins.attrNames (lib.filterAttrs
    (name: type: type == "regular" && lib.hasSuffix ".zsh" name)
    (builtins.readDir scriptDir));
  sourceModules = lib.concatMapStringsSep "\n" (name: "source ${scriptDir}/${name}") customModules;
in {
  home.packages = with pkgs; [
    bat
    fnm
    uv
  ];

  programs.zsh = {
    enable = true;

    #环境变量
    sessionVariables = {
      WORKON_HOME = "${config.home.homeDirectory}/Documents/code/python/.venvs";
    };
    # 别名
    shellAliases = {
      v = "nvim";
      cat = "bat --paging=never --style=plain";
    };

    oh-my-zsh = {
      enable = true;
      plugins = ["git" "web-search"];
    };
    # 自动管理语法高亮和自动补全（无需手动克隆）
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    # 插件列表：处理非内置的插件或主题
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];
    # 利用 initContent 的权重机制管理不同配置块
    initContent = lib.mkMerge [
      # 权重 500: p10k 瞬时提示 (Instant Prompt)
      (lib.mkOrder 500 ''
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')

      # 权重 1000: 你的自定义逻辑
      (lib.mkOrder 1000 ''
        # 加载 p10k 配置
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
        #自动注入所有scripts目录下的脚本
        ${sourceModules}

        # 工具链初始化
        eval "$(uv generate-shell-completion zsh)"
        eval "$(fnm env --use-on-cd)"
      '')
    ];
  };

  # 将 p10k 配置文件下发到 Home 目录
  home.file.".p10k.zsh".source = ./p10k.zsh;
}
