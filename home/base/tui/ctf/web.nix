{ pkgs, ... }: {
  home.packages = with pkgs; ([
    sqlmap # a inject tools for mysql database
  ]);
}
