{ config, pkgs, lib, ... }:

{
  fd.enable = true;
  
  bat.enable = true;

  fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --hidden --strip-cwd-prefix --exclude .git";
    defaultOptions = ["--height 40%" "--layout=reverse" "--border"];
    fileWidgetCommand = "fd --hidden --strip-cwd-prefix --exclude .git";
    fileWidgetOptions = [
      "--preview 'if [ -d {} ]; then eza --tree --all --level=3 --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi'"
    ];
    changeDirWidgetCommand = "fd --type d --hidden --strip-cwd-prefix --exclude .git";
    changeDirWidgetOptions = ["--preview 'eza --tree --color=always {} | head -200'"];
  };

  zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [
      "--cmd cd"
    ];
  };

  eza = {
    enable = true;
    git = true;
    icons = true;
  };

  yazi = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      manager = {
        show_hidden = true;
        ratio = [ 1 3 4 ];
      };
    };
  };
}