{...}: {
  programs.eza = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    extraOptions = [
      "--color=always"
      "--group-directories-first"
      "--header"
      "--time-style=long-iso"
    ];
    theme = import ./theme.nix;
    git = true;
    icons = "always";
  };
  programs.zsh.shellAliases = {
    tree = "eza --tree";
  };
}
