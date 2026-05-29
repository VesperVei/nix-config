{ ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "VseperVei";
        email = "3454731266@qq.com";
      };

      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;

      core.editor = "nvim";

      color.ui = "auto";
    };
  };
}
