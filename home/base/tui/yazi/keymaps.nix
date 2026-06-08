{
  input.prepend_keymap = [
  ];
  mgr.prepend_keymap = [
    {
      on = ["l"];
      run = "plugin smart-enter";
    }
    {
      on = ["<Enter>"];
      run = "plugin smart-enter";
    }
    {
      on = ["S"];
      run = "shell '$SHELL' --block --confirm";
    }

    # Goto
    {
      on = ["g" "r"];
      run = "cd /";
      desc = "Go to the root directory";
    }
    {
      on = ["g" "h"];
      run = "cd ~";
      desc = "Go to the home directory";
    }
    {
      on = ["g" "c"];
      run = "cd ~/.config";
      desc = "Go to the config directory";
    }
    {
      on = ["g" "g"];
      run = "arrow top";
      desc = "Go to top";
    }
    {
      on = "G";
      run = "arrow bot";
      desc = "Go to end";
    }

    # Find
    {
      on = "<C-p>";
      run = "plugin fzf";
      desc = "Jump to a directory or reveal a file using fzf";
    }
    {
      on = ["z" "o"];
      run = "plugin zoxide";
      desc = "Jump to a directory using zoxide";
    }
    {
      on = "f";
      run = "search fd";
      desc = "Search files by name using fd";
    }
    {
      on = "F";
      run = "search rg";
      desc = "Search files by content using ripgrep";
    }
    {
      on = "<C-s>";
      run = "escape --search";
      desc = "Cancel the ongoing search";
    }
    {
      on = "f";
      run = "filter --smart";
      desc = "Filter files";
    }
    {
      on = "/";
      run = "find --smart";
      desc = "Find next file";
    }
    {
      on = "?";
      run = "find --previous --smart";
      desc = "Find previous file";
    }
    {
      on = "n";
      run = "find_arrow";
      desc = "Go to the next found";
    }
    {
      on = "N";
      run = "find_arrow --previous";
      desc = "Go to the previous found";
    }
  ];
}
